require 'base64'
require 'openssl'
require 'securerandom'
require 'pry'
require 'json'

class AtlanticNetException < StandardError
  attr_reader :atlantic_net_instance, :api_response

  def initialize(instance, response, message)
    super(message)
    @atlantic_net_instance = instance
    @api_response = response
  end
end

class AtlanticNet

  VERSION = "2010-12-30"
  FORMAT =  "json"

  class HttpTransport

    API_URI = "https://cloudapi.atlantic.net"

    # Sends the request to the API endpoint
    #
    # @param [Hash] data The Data to pass with the request
    #
    def send_request (data)
      uri = URI.parse(API_URI)
      uri.query = URI.encode_www_form(data)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      response = http.get(uri.request_uri)

      unless response.code.to_i == 200
        fail AtlanticNetException.new(nil, {}, "The Atlantic.net api endpoint was unexpectedly unavailable. The HTTP Status code was #{response.code}")
      end

      JSON.parse(response.body)
    end
  end

  # @param [String] access_key The Access Key for your Account.
  #   This is the "API Public Key" from the Account Settings page.
  #
  # @param [String] private_key The Private Key for your Account.
  #   This is the "API Private Key" from the Account Settings page.
  #
  def initialize(access_key, private_key, options = {})
    @access_key = access_key
    @private_key = private_key
    @transport = transport_from_options(options)
  end

  # Generates a Base64 encoded Sha256 HMAC given a timestamp and a request_id
  #
  # @param [String,Int] timestamp The timestamp of the requesting call.
  #   This should be the time the the request was originally made.
  #
  # @param [String] request_id The UUID representing the request.
  #   This should be unique for each request.
  #
  # @return [String] A Base64 encoded HMAC of the timestamp and request_id 
  #
  def signature(timestamp, request_id)
    string_to_sign = "#{timestamp}#{request_id}"

    digest = OpenSSL::Digest.new('sha256')
    Base64.encode64(OpenSSL::HMAC.digest(digest, @private_key, string_to_sign)).strip()
  end

  # Retrieve the list of currently active cloud servers.
  #
  # @return [Array<Hash>] The list of servers
  #
  def list_instances
    response = api_call('list-instances')
    instances = response['list-instancesresponse']['instancesSet']
    if instances
      instances.values
    else
      []
    end
  end

  # Restart a specific cloud server.
  #
  # @param [String] instance_id The instance ID of the server you want to reboot.
  # 
  # @param [Hash] options The options to include with restart.
  # @option options [String] :reboot_type (soft) Whether you want to perform a soft or hard reboot.
  #   soft is the equivalent of performing a graceful shutdown.
  #   hard is the equivalent of disconnecting the power and reconnecting it.
  #
  # @return [Hash] The return value of the request
  #
  def reboot_instance(instance_id, options={})
    reboot_type = options[:reboot_type] || "soft"
    response = api_call('reboot-instance', {instanceid: instance_id, reboottype: reboot_type})
    reboot_response = response["reboot-instanceresponse"]
    if reboot_response.has_key? "return"
      response["reboot-instanceresponse"]["return"]
    else
      response["reboot-instanceresponse"]["instancesSet"]["item"]
    end
  end

  # Describe a specific cloud server.
  #
  # @param [String] instance_id The instance ID of the server you want to describe.
  #
  # @return [Hash] The hash of the instance
  #
  def describe_instance(instance_id)
    response = api_call('describe-instance', {instanceid: instance_id})
    response["describe-instanceresponse"]["instanceSet"]["item"]
  end

  # Terminate a specific cloud server.
  #
  # @param [String] instance_id The instance ID of the server you want to terminate.
  #
  # @return [Hash] The termination response result.
  #
  def terminate_instance(instance_id)
    response = api_call('terminate-instance', {instanceid: instance_id})
    response["terminate-instanceresponse"]["instancesSet"]["item"]
  end

  # Run a cloud server with the provided configuration options. 
  #
  # @param [String] server_name The name/description that will be used for the instance
  #
  # @param [String] plan_name The plan that should be used for this instance
  #
  # @param [String] vm_location The data center location you want this instance launched
  #
  # @param [Hash] args A hash of the options
  # @option options [String] :image_id The VM image to use for this instance. This or :clone_image are required.
  # @option options [String] :clone_image The server to clone for this instance. This or :image_id are required.
  # @option options [Boolean] :enable_backup Whether backups should be enabled for this instance.
  # @option options [Int] :server_quantity How many instances of this server should be launched.
  # @option options [String] :key_id The ID of the key to deploy for accessing this server.
  #
  # @return [Hash] The run instance result
  #
  def run_instance(server_name, plan_name, vm_location, options={})
    option_mapping = {
      image_id: :imageid,
      clone_image: :cloneimage,
      enable_backup: :enablebackup,
      server_quantity: :serverqty,
      key_id: :key_id
    }

    request_options = {servername: server_name, planname: plan_name, vm_location: vm_location}

    unless options.has_key? :image_id or options.has_key? :clone_image
      fail ArgumentError.new("Missing argument: image_id or clone_image are required")
    end

    option_mapping.each do | key, value |
      if options.has_key? key
        request_options[value] = options[key]
      end
    end

    response = api_call('run-instance', request_options)
    response["run-instanceresponse"]["instancesSet"]["item"]
  end

  # Retrieve the description of all available cloud images or the description of a specific cloud image by providing the image id 
  #
  # @param [Hash] options A hash of the options
  # @option options [String] :image_id ID indicating the flavor and version number of the operating system image
  #
  # @return [Array<Hash>] A array of image descriptions
  #
  # @raise [AtlanticNetException] if the image_id specified in the options does not
  #   match an image id on Atlantic.net
  #
  def describe_images(options={})
    args = {}

    if options.has_key? :image_id
      response = api_call('describe-image', {imageid: options[:image_id]})
    else
      response = api_call('describe-image')      
    end

    response["describe-imageresponse"]["imagesset"].values
  end

  # Retrieve a list of available cloud server plans, narrow the listing down optionally
  # by server platform, or get information about just one specific plan
  #
  # @param [Hash] options A hash of the options
  # @option options [String] plan_name The name of the plan to describe
  # @option options [String] platform The platform to filter plans by (windows, linux)
  #
  # @return [Array<Hash>] An array of plan descriptions
  #
  def describe_plans(options={})
    if options.empty?
      response = api_call('describe-plan')
    else
      response = api_call('describe-plan',options)
    end

    plans = response["describe-planresponse"]["plans"]
    if plans.respond_to?(:values)
      plans.values
    else
      []
    end
  end

  # Retrieve the details of all SSH Keys associated with the account
  #
  # @return [Array<Hash>] An array of SSH keys
  #
  def list_ssh_keys
    response = api_call('list-sshkeys')
    keys_set = response["list-sshkeysresponse"]["KeysSet"]
    if keys_set
      keys_set.values
    else
      []
    end
  end


protected

  # Generate the next timestamp and request_id combination 
  #
  # @return [Int, String] timestamp, request_id
  #
  def generate_request_id_tuple
    timestamp = Time.now().to_i
    request_uuid = SecureRandom.uuid
    [timestamp, request_uuid]
  end

  # Performs the request and sends it off to the transport
  #
  # @param [String] action The API Action to perform.
  #
  # @param [Hash] args The arguments to pass with the request to the API.
  #
  def api_call(action, args = {})
    timestamp, request_id = generate_request_id_tuple()
    request_signature = signature(timestamp, request_id)

    args = args.merge(
      Version: VERSION,
      ACSAccessKeyId: @access_key,
      Format: FORMAT,
      Timestamp: timestamp,
      Rndguid: request_id,
      Signature: request_signature,
      Action: action
    )

    response = @transport.send_request(args)
    if response.has_key? "error"
      fail AtlanticNetException.new(self, response, response["error"]["message"])
    end

    response
  end

private

  def transport_from_options(options)
    options[:transport] || AtlanticNet::HttpTransport.new
  end

end
