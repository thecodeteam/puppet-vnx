Puppet::Type.newtype(:vnx_dns) do 
  @doc = "Manage EMC VNX DNS settings."
  
  ensurable
  
  newparam(:domain, :namevar => true) do 
    desc "The DNS Domain name"
  end
 
  newproperty(:name_servers, :array_matching => all) do
    desc "The DNS name server IPv4 addresses."
    validate do |value|
      fail("Invalid IP address specified for nameserver") unless IPAddr.new(value).ipv4?
    end
  end

  newproperty(:search_list, :array_matching => all) do
    desc "The DNS search list."
  end
  
end
