# Copyright (C) 2014 EMC, Inc.
Puppet::Type.newtype(:vnx_ntp) do 
  @doc = "Manage EMC VNX NTP settings."
  
  ensurable
  
  newproperty(:ensure_running) do 
    desc "Control whether NTP is started or not"
    defaultto :no
    newvalues(:yes, :no)
  end
 
  newproperty(:interval) do
    desc "The synchronization interval in minutes from 30 to 43200."
    validate do |value|
      fail("Invalid range for NTP") unless value.is_a? Integer and value >= 30 and value <= 43200
    end
  end

  newparam(:ntp_servers, :namevar => true, :array_matching => all) do
    desc "The NTP server address."
    validate do |value|
      fail("#{value} is not a valid value IPV4 address") unless IPAddr.new(value).ipv4?
    end   
  end
  
  newparam(:server_key, :array_matching => :all) do
   desc "The NTP server key value."
    validate do |value|
      fail("Server_key values must be integer values") unless value.is_a? Integer 
      fail("Server_key out of accepted range") unless value >= 0 and value <= 65534   
    end
  end


  newparam(:keyvalue, :array_matching => :all) do
    desc "The NTP keyvalue for authentication."
    validate do |value|
      fail ("#{value} is not a valid keyvalue for NTP") unless value.length <= 16 and keyval =~ /^[ -~]+$/ and !(keyval =~ /#/)
    end
  end

  validate do
    fail("Cannot specify server_key without keyvalue") if self[:server_key] and self[:keyvalue].nil?
    fail("Cannot specify keyvalue without server_key") if self[:keyvalue] and self[:server_key].nil?
    fail("Invalid number of serverkey/keyvalue pairs") if self[:server_key].length != self[:keyvalue].length
    if :ensure_running == :yes
      fail("Must specify servers and interval") unless self[:servers] and self[:interval]
    end
  end


end
