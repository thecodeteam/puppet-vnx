begin
  require 'puppet_x/puppetlabs/transport/emc_vnx'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  puts "MODULE LIB IS #{module_lib}"
  require File.join module_lib, 'puppet_x/puppetlabs/transport/emc_vnx'
end

Puppet::Type.type(:vnx_initiator).provide(:vnx_initiator) do
  include PuppetX::Puppetlabs::Transport::EMCVNX

  desc "Manage Hosts/Initiators for VNX."

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def get_instances
    initiators = []
    initiator_lines = run(%w[port -list -hba]).split("Information about each HBA:\n\n")
    initiator_lines.each do |line_info|
      next if line_info =~ /\A\s+\z/ #skip blank line
    	initiator_info = {}
      hba_info, hba_ports = line_info.split "Information about each port of this HBA:\n\n"
      hba_info.split("\n").each do |line|
        if (pattern = 'HBA UID:') && line.start_with?(pattern)
          initiator_info[:hba_uid] = line.sub(pattern, '').strip
          next
        end

        if (pattern = 'Server Name:') && line.start_with?(pattern)
          initiator_info[:hostname] = line.sub(pattern, '').strip
          next
        end

        if (pattern = 'Server IP Address:') && line.start_with?(pattern)
          initiator_info[:ip_address] = line.sub(pattern, '').strip
          initiator_info[:ip_address] = nil if initiator_info[:ip_address] == "UNKNOWN"
          next
        end
      end

      ports = []
      hba_ports.split("\n\n").each do |port_info|
        port = {}
        port_info.split("\n").each do |line|
          line.strip!

          if (pattern = 'SP Name:') && line.start_with?(pattern)
            port[:sp] = (line.sub(pattern, '').strip == "SP A" ? :a : :b)
            next
          end

          if (pattern = 'SP Port ID:') && line.start_with?(pattern)
            port[:sp_port] = line.sub(pattern, '').strip.to_i
            next
          end

          if (pattern = 'StorageGroup Name:') && line.start_with?(pattern)
            port[:storage_group_name] = line.sub(pattern, '').strip
            next
          end

        end
        ports << port unless port.empty?
      end
      initiator_info[:ensure] = :present
      initiator_info[:ports] = ports
      initiators << initiator_info
    end
    initiators
  end

  def exists?
    get_instances.find{|initiator| initiator[:hba_uid] == resource[:hba_uid]}
  end

  def set_initiator
    resource[:ports].each do |port|
      if port["storage_group"]
        gname = port["storage_group"]
      #else
      #  gname = create_temp_storage_group
      end

      begin
        #debug "Try to create #{resource[:name]} #{resource[:ip_address]}, #{resource[:hostname]} on #{port[:storagegroup]} #{port[:so]} #{port[:sp_port]}"
        command = ["storagegroup", "-setpath", "-hbauid", resource[:hba_uid], "-sp", port["sp"], "-spport", port["sp_port"].to_s, "-o"]
        if resource[:ip_address] != nil
        	command += ["-ip",resource[:ip_address]]
        end
        
        if resource[:hostname] != nil
        	command +=["-host",resource[:hostname]]
        end
        
		if resource[:failovermode] != nil
			command +=["-failovermode", resource[:failovermode]]
		end
		
		if resource[:arraycommpath] != nil
			command +=["-arraycommpath", resource[:arraycommpath]]
		end
		
        if gname != nil
        	command += ["-gname", gname] 
        end
        run(command)
      ensure
        #destroy_temp_storage_group(resource[:hostname], gname) unless port["storage_group"]
      end
    end
    @property_hash[:ensure] = :present
  end

 # def create_temp_storage_group
    #create a temporary storage group for registering a new initiator 
 #   gname = "TmpSG" + Time.now.to_i.to_s
 #   pre_command = ["storagegroup", "-create", "-gname", gname]
 #   run(pre_command)
 #   gname
 # end

 # def destroy_temp_storage_group(hostname, gname)
 #   #destroy temporary storage group
 #   begin
 #     post_command = ["storagegroup", "-disconnecthost", "-host", hostname, "-gname", gname, "-o"]
 #     run(post_command)
 #   ensure
 #     post_command = ["storagegroup", "-destroy", "-gname", gname, "-o"]
 #     run(post_command)
 #   end
 # end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    if @property_flush[:ensure] == :absent
      run(["port", "-removeHBA", "-o", "-hbauid", resource[:hba_uid]])
    else
      set_initiator
    end
  end

end
