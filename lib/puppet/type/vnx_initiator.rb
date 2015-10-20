Puppet::Type.newtype(:vnx_initiator) do
  @doc = "VNX Initiator/Hosts."

  ensurable

  newparam(:hbauid, :namevar => true) do
    desc "The HBA UID for an Initiator"
  end

  newparam(:hba_uid) do
    desc "The HBA UID for an Initiator not name"
  end

  newproperty(:failovermode) do
  	desc "failover mode"
  end
  
  newproperty(:arraycommpath) do
  	desc "Array Comm Path"
  end


  newproperty(:hostname) do
    desc "The host name of virtual machine"
  end

  newproperty(:ip_address) do
    desc "The IP address of virtual machine"
    validate do |value|
      fail("#{value} is not a valid IPv4 address") unless value.nil? || IPAddr.new(value).ipv4?
    end
  end

  newproperty(:ports, :array_matching => :all) do
    desc "Information about each port of this HBA"
  end

#  newparam(:sp) do
#    desc "The sevice port to register"
#    newvalues(:a, :b)
#  end

#  newparam(:sp_port) do
#    desc "SP port"
#    newvalues(0, 1)
#  end

#  newproperty(:storage_group_name) do
#    desc "Storage Group name."
#  end

#  newproperty(:storage_group_uid) do
#    desc "Storage Group uid."
#    validate do |value|
#      fail("#{value} is not a Integer") unless value.is_a? Integer
#    end
#  end
end
