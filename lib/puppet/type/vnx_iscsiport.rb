Puppet::Type.newtype(:vnx_iscsiport) do 
  @doc = "Manage EMC VNX ISCSI Port settings."
  
  ensurable
  
  newparam(:name, :namevar => true) do
    desc "The VNX SP Port to configure"
    newvalues(:spa_0, :spa_1, :spb_0, :spb_1)
  end

  newparam(:vportid) do
    desc "The virtual Port ID."
    munge do |value|
      value = '0' unless self[:vportid]
    end
    validate do |value|
      fail("Vportid must be an integer") unless value.is_a? Integer
    end   
  end
  
  newparam(:vlanid) do
   desc "The Port VLAN ID"
    validate do |value|
      fail ("#{value} is not a valid VLAN VALUE") unless value >= 0 and value <= 4095
    end
  end

  newparam(:enable_vlantag) do
    desc "Allows enabling or disabling of VLAN tagging"
    defaultto :false
    newvalues(:true, :false)
  end

  newparam(:address) do 
    desc "THe IP Address of the SP Port"
    validate do |value|
      fail("#{value} is not a valid IPv4 address") unless IPAddr.new(value).ipv4?
    end
  end

  newparam(:subnetmask) do 
    desc "The Subnet Mask for the SP Port"
    validate do |value|
      fail("#{value} is not a valid Subnet") unless IPAddr.new(value).ipv4?
    end
  end

  newparam(:gateway) do
    desc "The gateway address for the SP Port"
    validate do |value|
      fail("#{value} is not a valid Gateway address") unless IPAddr.new(value).ipv4?
    end
  end

  newparam(:initiator_authenticate) do
    desc "True sets this value to 0 or not required, False sets to 1 and required"
    defaultto :false
    newvalues(:true, :false)
  end

  newparam(:alias) do
    desc "The iSCSI port Alias"
  end

  newparam(:port_speeed) do
    desc "The Port speed"
  end
  
  newparam(:mtu) do
    desc "The MTU for the port"
    validate do |value|
      fail("Invalid MTU size") unless value < 9000
    end
  end

end
