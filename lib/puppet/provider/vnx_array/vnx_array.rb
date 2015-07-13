Puppet::Type.type(:vnx_array).provide(:vnx_array) do
  desc "Manage VNX Array name."
  
  def self.instances
    arrayname = run("arrayname").gsub("Array Name:", '').strip
    new(:name => arrayname)
  end

  def exists
    @property_hash[:ensure] == :present
  end
    
  def create
    run("arrayname", resource[:name], "-o")
    @property_hash[:ensure] = :present
  end

  def destroy
    # No method to destroy DNS settings so leave action blank
    @property_hash[:ensure] = :absent
  end

end

