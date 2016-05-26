# atlantic_net

[![Build Status](https://travis-ci.org/jrstarke/atlantic_net.png?branch=master)](https://travis-ci.org/jrstarke/atlantic_net)
[![Coverage Status](https://coveralls.io/repos/jrstarke/atlantic_net/badge.png)](https://coveralls.io/r/jrstarke/atlantic_net)

A lightweight ruby interface for interacting with the Atlantic.net API.

## Installation

Add atlantic_net to your Gemfile:

``` ruby
gem "atlantic_net"
```

## Usage

``` ruby
# Require the atlantic_net library
require 'atlantic_net'

# Instantiate the client with your access key and private key
client = AtlanticNet.new(access_key, private_key)

# List instances
instances = client.list_instances

# Reboot an instance
subject.reboot_instance(instances.first["InstanceId"])
```
