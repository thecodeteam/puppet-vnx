Puppet::Type.newtype(:vnx_array) do 
  @doc = "Manage EMC VNX Array name."
  
  ensurable
  
  newparam(:name, :namevar => true) do 
    desc "The name for the VNX Array"
    validate do |value|
      fail("Length of name cannot exceed 64 characters") if value.length >64
    end
  end
 

end
