require "spec_helper"

describe AtlanticNet do
  let(:subject) { AtlanticNet.new(access_key, private_key, options) }

  let(:access_key) { "public_key" }
  let(:private_key) { "secret" }

  let(:options) { { transport: transport } }
  let(:transport) { double(:transport, send_request: {}) }
  
  let(:sample_timestamp) { "Mess" }
  let(:sample_request_id) { "age" }
  let(:sample_signature) { "qnR8UCqJggD55PohusaBNviGoOJ67HC6Btry4qXLVZc=" }

  describe "#signature" do
    it 'returns sample signature' do
      signature = subject.signature(sample_timestamp,sample_request_id)
      expect(signature).to eq sample_signature
    end
  end

  describe "#list_instances" do
    let(:sample_api_response) { 
      {
        "Timestamp" => 1440018626,
        "list-instancesresponse" => {
          "instancesSet" => {
            "1item" => {
              "InstanceId" => "145607",
              "cu_id" => "17",
              "rate_per_hr" => "0.0341",
              "vm_bandwidth" => "600",
              "vm_cpu_req" => "1",
              "vm_created_date" => "1438048503",
              "vm_description" => "New",
              "vm_disk_req" => "40",
              "vm_image" => "CentOS-7.1-cPanel_64bit",
              "vm_image_display_name" => "CentOS 6.5 64bit Server - cPanel/WHM",
              "vm_ip_address" => "209.208.65.177",
              "vm_name" => "17-145607",
              "vm_network_req" => "1",
              "vm_os_architecture" => "64",
              "vm_plan_name" => "S",
              "vm_ram_req" => "1024",
              "vm_status" => "RUNNING"
            },
            "item" => {
              "InstanceId" => "153979",
              "cu_id" => "17",
              "rate_per_hr" => "0.0547",
              "vm_bandwidth" => "600",
              "vm_cpu_req" => "2",
              "vm_created_date" => "1440018294",
              "vm_description" => "apitestserver",
              "vm_disk_req" => "100",
              "vm_image" => "ubuntu-14.04_64bit",
              "vm_image_display_name" => "ubuntu-14.04_64bit",
              "vm_ip_address" => "45.58.35.251",
              "vm_name" => "17-153979",
              "vm_network_req" => "1",
              "vm_os_architecture" => "64",
              "vm_plan_name" => "L",
              "vm_ram_req" => "4096",
              "vm_status" => "RUNNING" 
            }
          },
          "requestid" => "c2a1bc2a-4440-438a-bd28-74dbc10a4047"
        }
      }
    }
    let(:expected_instances) {
      [
        {
          "InstanceId" => "145607",
          "cu_id" => "17",
          "rate_per_hr" => "0.0341",
          "vm_bandwidth" => "600",
          "vm_cpu_req" => "1",
          "vm_created_date" => "1438048503",
          "vm_description" => "New",
          "vm_disk_req" => "40",
          "vm_image" => "CentOS-7.1-cPanel_64bit",
          "vm_image_display_name" => "CentOS 6.5 64bit Server - cPanel/WHM",
          "vm_ip_address" => "209.208.65.177",
          "vm_name" => "17-145607",
          "vm_network_req" => "1",
          "vm_os_architecture" => "64",
          "vm_plan_name" => "S",
          "vm_ram_req" => "1024",
          "vm_status" => "RUNNING"
        },
        {
          "InstanceId" => "153979",
          "cu_id" => "17",
          "rate_per_hr" => "0.0547",
          "vm_bandwidth" => "600",
          "vm_cpu_req" => "2",
          "vm_created_date" => "1440018294",
          "vm_description" => "apitestserver",
          "vm_disk_req" => "100",
          "vm_image" => "ubuntu-14.04_64bit",
          "vm_image_display_name" => "ubuntu-14.04_64bit",
          "vm_ip_address" => "45.58.35.251",
          "vm_name" => "17-153979",
          "vm_network_req" => "1",
          "vm_os_architecture" => "64",
          "vm_plan_name" => "L",
          "vm_ram_req" => "4096",
          "vm_status" => "RUNNING" 
        }
      ]
    }

    # it 'calls api_call with list-instances api' do
    #   expect(subject).to receive(:api_call).with("list-instances").and_return(sample_api_response)
    #   subject.list_instances
    # end

    it 'calls api_call with list-instances and returns a list of instance hashes' do
      allow(subject).to receive(:api_call).with("list-instances").and_return(sample_api_response)
      instances = subject.list_instances
      expect(instances).to eq expected_instances
    end
  end

  describe '#reboot_instance' do
    let(:instance_id) { "234" }
    let(:sample_api_response) {
      {
        "Timestamp" => 1440171938,
        "reboot-instanceresponse" => {
          "requestid" => "6723430f-c416-46de-a03d-2d2ea38d3af7",
          "return" => {
            "Message" => "Successfully queued for reboot",
            "value" => "true"
          }
        }
      }
    }
    let(:expected_return) {
      {
        "Message" => "Successfully queued for reboot",
        "value" => "true"
      }
    }

    context "default options" do
      let(:reboot_type) { "soft" }
      
      it 'calls api_call with reboot-instance and instance_id' do
        expect(subject).to receive(:api_call)
          .with("reboot-instance", {instanceid: instance_id, reboottype: reboot_type})
          .and_return(sample_api_response)
        result = subject.reboot_instance(instance_id)
        expect(result).to eq expected_return
      end
    end
    
    context "reboot_type override" do
      let(:reboot_type) { "hard" }

      it 'calls api_call with reboot-instance, instance_id and reboot_type' do
        expect(subject).to receive(:api_call)
          .with("reboot-instance", {instanceid: instance_id, reboottype: reboot_type})
          .and_return(sample_api_response)
        result = subject.reboot_instance(instance_id, reboot_type: reboot_type)
        expect(result).to eq expected_return
      end
    end
  end

  describe "#describe_instance" do
    let(:instance_id) { "234" }
    let(:sample_api_response) {
      {
        "Timestamp" => 1440020019,
        "describe-instanceresponse" => {
          "instanceSet" => {
            "item" => {
              "InstanceId" => "153979",
              "cloned_from" => "",
              "cu_id" => "17",
              "disallow_deletion" => "N",
              "rate_per_hr" => "0.0547",
              "removed" => "N",
              "reprovisioning_processed_date" => nil,
              "resetpwd_processed_date" => nil,
              "vm_bandwidth" => "600",
              "vm_cpu_req" => "2",
              "vm_created_date" => "1440018294",
              "vm_description" => "apitestserver",
              "vm_disk_req" => "100",
              "vm_id" => "153979",
              "vm_image" => "ubuntu-14.04_64bit",
              "vm_image_display_name" => "ubuntu-14.04_64bit",
              "vm_ip_address" => "45.58.35.251",
              "vm_ip_gateway" => "45.58.34.1",
              "vm_ip_subnet" => "255.255.254.0",
              "vm_network_req" => "1",
              "vm_os_architecture" => "64",
              "vm_plan_name" => "L",
              "vm_ram_req" => "4096",
              "vm_removed_date" => nil,
              "vm_status" => "RUNNING",
              "vm_username" => "root",
              "vm_vnc_password" => "8$EOs$Rs",
              "vnc_port" => "18248"
            }
          },
          "requestid" => "3affbe87-ad45-41de-a1d2-29b522aa88b2"
        }
      }
    }
    let(:expected_instance) {
      {
        "InstanceId" => "153979",
        "cloned_from" => "",
        "cu_id" => "17",
        "disallow_deletion" => "N",
        "rate_per_hr" => "0.0547",
        "removed" => "N",
        "reprovisioning_processed_date" => nil,
        "resetpwd_processed_date" => nil,
        "vm_bandwidth" => "600",
        "vm_cpu_req" => "2",
        "vm_created_date" => "1440018294",
        "vm_description" => "apitestserver",
        "vm_disk_req" => "100",
        "vm_id" => "153979",
        "vm_image" => "ubuntu-14.04_64bit",
        "vm_image_display_name" => "ubuntu-14.04_64bit",
        "vm_ip_address" => "45.58.35.251",
        "vm_ip_gateway" => "45.58.34.1",
        "vm_ip_subnet" => "255.255.254.0",
        "vm_network_req" => "1",
        "vm_os_architecture" => "64",
        "vm_plan_name" => "L",
        "vm_ram_req" => "4096",
        "vm_removed_date" => nil,
        "vm_status" => "RUNNING",
        "vm_username" => "root",
        "vm_vnc_password" => "8$EOs$Rs",
        "vnc_port" => "18248"
      }
    }

    it 'calls api_call with describe-instance and returns an instance hash' do
      expect(subject).to receive(:api_call)
        .with("describe-instance", {instanceid: instance_id})
        .and_return(sample_api_response)
      result = subject.describe_instance(instance_id)
      expect(result).to eq expected_instance
    end
  end

  describe "#terminate_instance" do
    let(:instance_id) { "234" }
    let(:sample_api_response) {
      {
        "Timestamp" => 1440175812,
        "terminate-instanceresponse" => {
          "instancesSet" => {
            "item" => {
              "InstanceId" => "154809",
              "message" => "queued for termination",
              "result" => "true"
            }
          },
          "requestid" => "4dec8ab5-29e7-48f3-934e-e4bc3101de80"
        }
      }
    }
    let(:termination_response) {
      {
        "InstanceId" => "154809",
        "message" => "queued for termination",
        "result" => "true"
      }
    }

    it 'calls api_call with terminate-instance and returns a termination response hash' do
      expect(subject).to receive(:api_call)
        .with("terminate-instance", {instanceid: instance_id})
        .and_return(sample_api_response)
      result = subject.terminate_instance(instance_id)
      expect(result).to eq termination_response
    end
  end

  describe "#run_instance" do
    let(:sample_api_response) {
      {
        "Timestamp" => 1440018190,
        "run-instanceresponse" => {
          "instancesSet" => {
            "item" => {
              "instanceid" => "153979",
              "ip_address" => "45.58.35.251",
              "password" => "8q%Q6KaQ",
              "username" => "root"
            }
          },
          "requestid" => "6396399d-cb7d-446a-91c6-1334d0f939d8"
        }
      }
    }
    let(:run_response) {
      {
        "instanceid" => "153979",
        "ip_address" => "45.58.35.251",
        "password" => "8q%Q6KaQ",
        "username" => "root"
      }
    }
    

    let(:server_name) {"apitestserver"}
    let(:image_id) {"ubuntu-14.04_64bit"}
    let(:plan_name) {"L"}
    let(:vm_location) {"USEAST2"}

    context "default parameters" do
      it 'calls the api with the servername, imageid, planname and vm_location' do
        expect(subject).to receive(:api_call)
          .with("run-instance", {servername: server_name, imageid: image_id, planname: plan_name, vm_location: vm_location})
          .and_return(sample_api_response)
        result = subject.run_instance(server_name, plan_name, vm_location, {image_id: image_id})
        expect(result).to eq run_response
      end
    end

    context "use clone_image instead of image_id" do
      let(:clone_image) {"17-145607"}

      it 'calls the api with the servername, cloneimage, planname and vm_location' do
        expect(subject).to receive(:api_call)
          .with("run-instance", {servername: server_name, cloneimage: clone_image, planname: plan_name, vm_location: vm_location})
          .and_return(sample_api_response)
        result = subject.run_instance(server_name, plan_name, vm_location, {clone_image: clone_image})
        expect(result).to eq run_response
      end
    end

    context "no image id or clone image are provided" do
      it 'raises an error when all the required arguments aren\'t specified' do 
        expect{subject.run_instance(server_name, plan_name, vm_location)}
        .to raise_error(ArgumentError)
      end
    end
    
    context "additional options" do
      let(:enable_backup) { true }
      let(:server_quantity) { 2 }
      let(:key_id) { "yt9p4y64f7dem3e" }

      it 'calls the api with the default arguments, plus enablebackup, serverqty and key_id' do
        expect(subject).to receive(:api_call)
          .with("run-instance", {
            servername: server_name, imageid: image_id, planname: plan_name, vm_location: vm_location,
            enablebackup: enable_backup, serverqty: server_quantity, key_id: key_id})
          .and_return(sample_api_response)
        result = subject.run_instance(server_name, plan_name, vm_location, {
          image_id: image_id, enable_backup: enable_backup, server_quantity: server_quantity, key_id: key_id
        })
        expect(result).to eq run_response
      end
    end
  end

  describe "#describe_images" do
    let(:sample_api_response) {
      {
        "Timestamp" => 1439933643,
        "describe-imageresponse" => {
          "imagesset" => {
            "1item" => {
              "architecture" => "x86_64",
              "displayname" => "Ubuntu 14.04 LTS Server 64-Bit",
              "image_type" => "os",
              "imageid" => "ubuntu-14.04_64bit",
              "ostype" => "linux",
              "owner" => "atlantic",
              "platform" => "linux",
              "version" => "14.04 LTS"
            }
          },
          "requestid" => "eb221f31-d023-452d-a7e9-9614fc575a9d"
        }
      }
    }
    let(:image_descriptions) {
      [
        {
          "architecture" => "x86_64",
          "displayname" => "Ubuntu 14.04 LTS Server 64-Bit",
          "image_type" => "os",
          "imageid" => "ubuntu-14.04_64bit",
          "ostype" => "linux",
          "owner" => "atlantic",
          "platform" => "linux",
          "version" => "14.04 LTS"
        }
      ]
    }

    context 'default options' do
      it 'calls api_call with describe-image and returns a list of image hashes' do
        expect(subject).to receive(:api_call)
          .with("describe-image")
          .and_return(sample_api_response)
        result = subject.describe_images
        expect(result).to eq image_descriptions
      end
    end

    context 'optional imageid' do
      let(:image_id) { "ubuntu-14.04_64bit" }
      it 'calls api_call with describe-image and a image_id string and returns a list of image hashes' do
        expect(subject).to receive(:api_call)
          .with("describe-image", {imageid: image_id})
          .and_return(sample_api_response)
        result = subject.describe_images({image_id: image_id})
        expect(result).to eq image_descriptions
      end
    end
  end

  describe "#describe_plans" do
    let(:sample_api_response) {
      {
        "Timestamp" => 1439932362,
        "describe-planresponse" => {
          "plans" => {
            "1item" => {
              "bandwidth" => 600,
              "centos_capable" => "Y",
              "cpanel_capable" => "Y",
              "disk" => "100",
              "display_bandwidth" => "600Mbits",
              "display_disk" => "100GB",
              "display_ram" => "4GB",
              "free_transfer" => "5",
              "num_cpu" => "2",
              "ostype" => "linux",
              "plan_name" => "L",
              "platform" => "linux",
              "ram" => "4096",
              "rate_per_hr" => 0.0547
            }
          },
          "requestid" => "4aae48ae-af7b-4bbd-9309-58aadbfd02d3"
        }
      }
    }
    let(:plan_descriptions) {
      [
        {
          "bandwidth" => 600,
          "centos_capable" => "Y",
          "cpanel_capable" => "Y",
          "disk" => "100",
          "display_bandwidth" => "600Mbits",
          "display_disk" => "100GB",
          "display_ram" => "4GB",
          "free_transfer" => "5",
          "num_cpu" => "2",
          "ostype" => "linux",
          "plan_name" => "L",
          "platform" => "linux",
          "ram" => "4096",
          "rate_per_hr" => 0.0547
        }
      ]
    }

    context 'default options' do
      it 'calls api_call with describe-plan and returns a list of plan hashes' do
        expect(subject).to receive(:api_call)
          .with("describe-plan")
          .and_return(sample_api_response)
        result = subject.describe_plans
        expect(result).to eq plan_descriptions
      end
    end

    context 'optional arguments' do
      let(:plan_name) { "L" }
      let(:platform) { "linux" }
      it 'calls api_call with describe-plan plan_name and platform and returns a list of image hashes' do
        expect(subject).to receive(:api_call)
          .with("describe-plan", {plan_name: plan_name, platform: platform})
          .and_return(sample_api_response)
        result = subject.describe_plans({plan_name: plan_name, platform: platform})
        expect(result).to eq plan_descriptions
      end
    end
  end

  describe "#list_ssh_keys" do
    let(:sample_api_response) {
      {
        "Timestamp" => 1457105502,
        "list-sshkeysresponse" => {
          "KeysSet" => {
            "item" => {
              "key_id" => "yt9p4y64f7dem3e",
              "key_name" => "My Public SSH Key",
              "public_key" => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAsdfAn4sozeeBHWCv6B/tkTcUFz47fg48FgasdfasdfJNp4T5Fyq+3/6BA6fdZoI9skdudkfy3n6IUxHr5fwIUD0tn7QNsn5jp9rpjVRuXqoHUP3OYh6ZSlPBnsVmRNOI2ZWiBqMCIsWaeUkenVfnmvLZ/eMVwoKiDhakHs1dvaB8X4kEc7DnXKDZEyy0hAb+Eei8ppUqs9uMq+utXLEMCk0cPMTtqMialvk1pnz2lMuVPw1HGNRh2mjyGI7+6DoPCHaYurDQMXcyfF+05pSpBZCQAVJWvZFzivGfzUOAc4bgFBLznECQ== user@workstation-206"
            }
          },
          "requestid" => "acea7888-a756-4ea1-b9db-6d2267673247"
        }
      }
    }
    let(:ssh_keys) {
      [
        {
          "key_id" => "yt9p4y64f7dem3e",
          "key_name" => "My Public SSH Key",
          "public_key" => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAsdfAn4sozeeBHWCv6B/tkTcUFz47fg48FgasdfasdfJNp4T5Fyq+3/6BA6fdZoI9skdudkfy3n6IUxHr5fwIUD0tn7QNsn5jp9rpjVRuXqoHUP3OYh6ZSlPBnsVmRNOI2ZWiBqMCIsWaeUkenVfnmvLZ/eMVwoKiDhakHs1dvaB8X4kEc7DnXKDZEyy0hAb+Eei8ppUqs9uMq+utXLEMCk0cPMTtqMialvk1pnz2lMuVPw1HGNRh2mjyGI7+6DoPCHaYurDQMXcyfF+05pSpBZCQAVJWvZFzivGfzUOAc4bgFBLznECQ== user@workstation-206"
        }
      ]
    }

    it 'calls api_call with list-sshkeys and returns a list of ssh key hashes' do
      expect(subject).to receive(:api_call)
        .with("list-sshkeys")
        .and_return(sample_api_response)
      result = subject.list_ssh_keys
      expect(result).to eq ssh_keys
    end
  end

  describe '#api_call' do
    it 'passes on the action' do
      expect(transport).to receive(:send_request).with(a_hash_including(Action: 'some-action'))
      subject.send(:api_call, 'some-action')
    end

    it 'includes a valid signature, public key, and timestamp' do
      allow(subject).to receive(:generate_request_id_tuple).and_return([ sample_timestamp, sample_request_id] )

      expect(transport).to receive(:send_request).with(a_hash_including(Signature: sample_signature, ACSAccessKeyId: access_key, Timestamp: sample_timestamp))
      subject.send(:api_call, 'some-action')
    end

    it 'passes on any arguments' do
      expect(transport).to receive(:send_request).with(a_hash_including(Value1: 'some-value-1', Value2: 'some-value-2'))
      subject.send(:api_call, 'someother-action', {:Value1 => "some-value-1", :Value2 => "some-value-2"})
    end

    it 'raises an exception if there is an error' do
      expect(transport).to receive(:send_request).and_return( JSON.parse('{"error":{"message": "Some error occurred"}}') )
      expect{subject.send(:api_call, 'some-erroneous-action')}.to raise_error(AtlanticNetException)
    end
  end

  describe '#generate_request_id' do
    it 'Uses Time to return epoc timestamp' do
      expect(Time).to receive(:now).and_return(double(:ts, to_i: 100))
      expect(subject.send(:generate_request_id_tuple).first).to eq(100)
    end

    it 'Returns a valid uuid for the request_id' do
      request_id = subject.send(:generate_request_id_tuple).last
      expect{ UUIDTools::UUID.parse(request_id)}.not_to raise_error
    end

    it 'Returns different request_ids for subsequent calls' do
      request_id1 = subject.send(:generate_request_id_tuple).last
      request_id2 = subject.send(:generate_request_id_tuple).last
      expect(request_id1).not_to eq (request_id2)
    end
  end
end

describe AtlanticNet::HttpTransport do
  let(:transport) { AtlanticNet::HttpTransport.new }
  let(:sample_data) { {"arg1" => "value1", "arg2" => "value2"} }
  let(:sample_response) { {"result1" => "response_value_1", "result2" => "response_value_2" }}

  describe "#send_request" do
    it "Passes the arguments and parses the response" do
      stub_request(:get, "https://cloudapi.atlantic.net").with(query: sample_data).to_return(body: sample_response.to_json)
      result = transport.send_request(sample_data)
      expect(result).to eq sample_response
    end

    it "raises an exception when request is unsuccessful" do
      stub_request(:get, "https://cloudapi.atlantic.net").to_return(status: 404)
      expect{transport.send_request({})}.to raise_error(AtlanticNetException)
    end
  end
end

describe AtlanticNetException do
  let(:atlantic_net_instance) { double }
  let(:api_response) { double }
  let(:message) { "an error message" }

  it 'Has the message, instance and api_response accessible' do
    atlantic_net_exception = AtlanticNetException.new(atlantic_net_instance, api_response, message)
    expect(atlantic_net_exception.atlantic_net_instance).to eq atlantic_net_instance
    expect(atlantic_net_exception.api_response).to eq api_response
    expect(atlantic_net_exception.message).to eq message
  end
end