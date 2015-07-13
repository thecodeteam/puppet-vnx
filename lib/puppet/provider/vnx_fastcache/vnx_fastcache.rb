Puppet::Type.type(:vnx_fastcache).provide(:vnx_fastcache) do

  desc "Manages VNX FAST Cache settings."

  ensurable
  
  def exists?
    fast = run('cache', '-fast', '-info')
    fast =~/Mode:  N\/A/ ? false : true
  end 


  def create
    run('cache', '-fast', '-create', '-disks', resource[:disks], '-mode', resource[:cache_mode], '-rtype', resource[:raid_type], '-o')
    @property_hash[:ensure] = :present
  end  


  def destroy
    result = run(%w[cache -fast -destroy])
    @property_hash[:ensure] = :absent
  end
 

end
