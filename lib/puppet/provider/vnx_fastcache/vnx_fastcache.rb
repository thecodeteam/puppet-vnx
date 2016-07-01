begin
  require 'puppet_x/puppetlabs/transport/emc_vnx'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  puts "MODULE LIB IS #{module_lib}"
  require File.join module_lib, 'puppet_x/puppetlabs/transport/emc_vnx'
end

Puppet::Type.type(:vnx_fastcache).provide(:vnx_fastcache) do
  include PuppetX::Puppetlabs::Transport::EMCVNX

  desc "Manages VNX FAST Cache settings."
  mk_resource_property_methods

  def initialize *args
    super
    @property_flush = {}
  end

  def get_current_properties
    fast_info = run(%w[cache -fast -info])
    #fast =~/Mode:  N\/A/ ? false : true
    self.class.get_fastcache_properties fast_info
  end
  
  def self.get_fastcache_properties fast_info
    fast = {}
    fast_info.split("\n").each do |line|
		if (pattern == "Mode:") && line.start_with?(pattern)
        	fast[:Mode] = line.sub(pattern, "").strip
        	#puts "wzz Debug: fastMode is #{fast[:Mode]}"
      	end
    end
    fast[:ensure] = fast[:Mode]=~/N\/A/ ? :absent : :present
    fast
  end

  # assume exists should be first called
  def exists?
  	#puts "#{current_properties[:ensure]}"
    current_properties[:ensure] == :present
  end
  
  
 # def exists?
 #   fast = run(%w[cache -fast -info])
 #   fast =~/Mode:  N\/A/ ? false : true
 # end 
	

  def create
  	args = ['cache', '-fast', '-create','-disks',*resource[:disks],'-mode',resource[:cache_mode],'-rtype', resource[:raid_type], '-o']
  	run(args)
    #run('cache', '-fast', '-create', '-disks', resource[:disks], '-mode', resource[:cache_mode], '-rtype', resource[:raid_type], '-o')
    #run(%w[cache -fast -create -disks *resource[:disks] -mode ,resource[:cache_mode] -rtype resource[:raid_type] -o])
    @property_hash[:ensure] = :present
  end  


  def destroy
    result = run(%w[cache -fast -destroy -o])
    #@property_hash[:ensure] = :absent
  end
 
   def flush
	  if exists?
	  	if @property_flush[:ensure] == :absent
	  		destroy
	  		return
	  	end
	  else
	  	create
	  end
  end

end
