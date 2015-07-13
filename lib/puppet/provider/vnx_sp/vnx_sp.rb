Puppet::Type.type(:vnx_sp).provide(:vnx_sp) do
  desc "Manage VNX Service Processor settings."

  mk_resource_methods
  
  def self.instances
    sps_instances =[]
    sps = ['a', 'b']
    sps.each do |sp |
      sps_info = run("networkadmin", "-get", "-sp", sp).split("\n")
      sps_info.each do |line|
        if line.include?("Network Name")
          name = line.gsub("Storage Processor Network Name:", '').strip
        elsif line =~/^Port ID/
          port_id = line.gsub("Port ID:", '').strip
        elsif line.include?("Subnet Mask")
          subnet_mask = line.scan(/\d+\.\d+\.\d+\.\d+/)
        elsif line.include?("IP Address")
          ip_address = line.scan(/\d+\.\d+\.\d+\.\d+/)
        elsif line.include?("Gateway Address")
          gateway = line.scan(/\d+\.\d+\.\d+\.\d+/)
        elsif line.include?("Virtual Port ID")
          vport = line.gsub("Virtual Port ID:", '').strip
        elsif line.include?("VLAN ID")
          vlan = line.gsub("VLAN ID:", '').strip
        end
        new sp_settings  = { :service_processor => sp,
                             :sp_name => sps,
                             :port_id => port_id,
                             :subnet_mask => subnet_mask,
                             :ip_address => ip_address,
                             :gateway => gateway,
                             :vport => vport,
                             :vlan => vlan }
        sps_instances << new(sp_settings)
      end
    end
    sps_instances
  end
  
  def self.prefetch(resources)
    sps = instances
    resources.keys.each do |name|
      if provider = sps.find{ |spname| spname.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists
    @property_hash[:ensure] == :present
  end
    
  def create
    # SP's are always present and we are only modifying SP paramaters
    # so create will not change anything
    @property_hash[:ensure] = :present
  end

  def flush
    @options = ["networkadmin", "-set", "-o", "-sp", resource[:service_processor]]
    if @property_hash[:ensure] == :present
      # If both name and IP addressing need to be changed, the network settings 
      # will be changed first, followed by the SP network name
      if resource[:sp_name] 
        if resource[:subnetmask] or resource[:gateway] or resource[:ip_address]
          @options << "-ipv4" << resource[:ip_address] if resource[:ip_address]
          @options << "-subnetmask" << resource[:subnetmask] if resource[:subnetmask]
          @options << "-gateway" << resource[:gateway] if resource[:gateway]
          run(@options)
        end
        @options << "-name" << resource[:sp_name] 
        run(@options)
      end
    end
  end
 
  def destroy
    # No method to destroy VNX name or IP settings in VNX so destroy does nothing
    @property_hash[:ensure] = :absent
  end

end

