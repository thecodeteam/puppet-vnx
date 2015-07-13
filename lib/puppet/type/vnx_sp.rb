Puppet::Type.newtype(:vnx_sp) do 
  @doc = "Manage EMC VNX SP name and IP settings."
  
  ensurable
  
  newparam(:service_processor, :namevar => true) do 
    desc "The Service Processor"
    newvalues(:a, :b)
  end

  newproperty(:sp_name) do
    desc "The Service Processor network name"
    validate do |value|
      fail("Length of name cannot exceed 64 characters") if value.length >64
    end
  end

  newparam(:ipaddress) do
    desc "The IPv4 address for the VNX SP"
    validate do |value|
      fail("Invalid IP address specified") unless IPAddr.new(value).ipv4?
    end
  end
  
  newparam(:subnetmask) do
    desc "The IP Subnet mask"
    validate do |value|
     fail("Invalid IP address for subnet mask") unless IPAddr.new(value).ipv4?
    end
  end

  newparam(:gateway) do
    desc "The IP gateway address"
    validate do |value|
    fail("Invalid IP address for gateway") unless IPAddr.new(value).ipv4?
    end
  end


end
