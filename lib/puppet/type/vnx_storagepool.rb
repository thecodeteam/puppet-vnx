begin
  require 'puppet_x/puppetlabs/transport/emc_vnx'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  puts "MODULE LIB IS #{module_lib}"
  require File.join module_lib, 'puppet_x/puppetlabs/transport/emc_vnx'
end

Puppet::Type.type(:vnx_storagepool).provide(:vnx_storagepool) do
  include PuppetX::Puppetlabs::Transport::EMCVNX

  desc "Manages VNX Storage Pools."

  mk_resource_property_methods

  def initialize *args
    super
    @property_flush = {}
  end

  def get_current_properties
    storagepool = run(["storagepool", "-list", "-name", resource[:name]])
    self.class.get_storagepool_properties(storagepool)
  end

  def self.get_storagepool_properties storagepool
    sp_info = { :ensure => :present }
    sp_lines = storagepool.split("\n")
    while line = sp_lines.shift
      if line.start_with?('Pool Name:')
        sp_name = line.gsub("Pool Name:", '').strip
        sp_info[:name] = sp_name
      end

      if line.start_with?('Pool ID:')
        value = line.gsub("Pool ID:", '').strip
        sp_info[:pool_id] = value
      end

      if line.start_with?('Raid Type:')
        value = line.gsub("Raid Type:", '').strip
        sp_info[:raid_type] = value
      end

      if line.start_with?('Percent Full Threshold:')
        value = line.gsub("Percent Full Threshold:", '').strip
        sp_info[:percent_full_threshold] = value
      end

      if line.start_with?('Description:')
        value = line.gsub("Description:", '').strip
        sp_info[:description] = value
      end

      if line.start_with?('Disk Type:')
        value = line.gsub("Disk Type:", '').strip
        sp_info[:disk_type] = value
      end

      if line.start_with?('State:')
        value = line.gsub("State:", '').strip
        sp_info[:state] = value.downcase.to_sym
      end

      if line.start_with?('Status:')
        value = line.gsub("Status:", '').strip
        sp_info[:status] = value
      end

      if line.start_with?('Current Operation:')
        value = line.gsub("Current Operation:", '').strip
        sp_info[:current_operation] = value
      end

      if line.start_with?('Current Operation State:')
        value = line.gsub("Current Operation State:", '').strip
        sp_info[:current_operation_state] = value
      end

      if line.start_with?('Current Operation Status:')
        value = line.gsub("Current Operation Status:", '').strip
        sp_info[:current_operation_status] = value
      end

      if line.start_with?('Current Operation Percent Completed:')
        value = line.gsub("Current Operation Percent Completed:", '').strip
        sp_info[:current_operation_percent_completed] = value
      end

      if (pattern = 'Raw Capacity (Blocks):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:raw_capacity_blocks] = value
        next
      end

      if (pattern = 'Raw Capacity (GBs):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:raw_capacity_gbs] = value
        next
      end

      if (pattern = 'User Capacity (Blocks):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:user_capacity_blocks] = value
        next
      end

      if (pattern = 'User Capacity (GBs):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:user_capacity_gbs] = value
        next
      end

      if (pattern = 'Consumed Capacity (Blocks):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:consumed_capacity_blocks] = value
        next
      end

      if (pattern = 'Consumed Capacity (GBs):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:consumed_capacity_gbs] = value
        next
      end

      if (pattern = 'Available Capacity (Blocks):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:available_capacity_blocks] = value
        next
      end

      if (pattern = 'Available Capacity (GBs):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:available_capacity_gbs] = value
        next
      end

      if (pattern = 'Percent Full:') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:percent_full] = value
        next
      end

      if (pattern = 'Total Subscribed Capacity (Blocks):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:total_subscribed_capacity_blocks] = value
        next
      end

      if (pattern = 'Total Subscribed Capacity (GBs):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:total_subscribed_capacity_gbs] = value
        next
      end

      if (pattern = 'Percent Subscribed:') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:percent_subscribed] = value
        next
      end

      if (pattern = 'Oversubscribed by (Blocks):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:oversubscribed_by_blocks] = value
        next
      end

      if (pattern = 'Oversubscribed by (GBs):') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:oversubscribed_by_gbs] = value
        next
      end

      if (pattern = 'Disks:') && line.start_with?(pattern)
        disks = []
        while /Bus (\d+) Enclosure (\d+) Disk (\d+)/ =~ sp_lines.first
          sp_lines.shift
          disks << "#{$1}_#{$2}_#{$3}"
        end
        sp_info[:disks] = disks
        next
      end

      if (pattern = 'LUNs:') && line.start_with?(pattern)
        value = line.gsub(pattern, '').strip
        sp_info[:luns] = value.split(",").map{|v| v.strip.to_i}
        next
      end
    end
    sp_info
  end

  # def self.instances
  #   storage_pools=[]
  #   output_lines = run(["storagepool", "-list"]).split("\n\n")
  #   output_lines.each do |line_info|
  #     storage_pools << new(get_storagepool_properties line_info)
  #   end
  #   storage_pools
  # end
  #
  # def self.prefetch(resources)
  #   vnx_storagepool = instances
  #   resources.keys.each do |name|
  #     if provider = vnx_storagepool.find{ |storagepool| storagepool.name == name }
  #       resources[name].provider = provider
  #     end
  #   end
  # end

  def set_storagepool
    run ["storagepool", "-cancelExpand", "-name", resource[:name]] if resource[:cancel_expand] == :true
    # raise error if resource disks less than current
    raise ArgumentError, "can't remove storagepool disks\ncurrent disks:#{current_properties[:disks]}\nchange to:#{resource[:disks]}" if resource[:disks] && !(current_properties[:disks] - resource[:disks]).empty?

    # run expand
    args = ["storagepool", "-expand", "-name", resource[:name]]
    origin_length = args.length + 1
    if @property_flush[:raid_type]
      args << "-rtype" << resource[:raid_type]
      if resource[:rdrive_count]
        args << "-rdrivecount" << resource[:rdrive_count]
      end
    end
    if @property_flush[:disks] && ((resource[:disks] || []).sort != (@property_hash[:disks] || []).sort)
      args << "-disks"
      args += (resource[:disks] - @property_hash[:disks])
    end
    args << "-initialverify" if resource[:initialverify] == :true
    args << "-skipRules" if resource[:skip_rules] == :true
    args << "-o"
    run(args) if args.length > origin_length

    # run modify
    args = ["storagepool", "-modify", "-name", resource[:name]]
    origin_length = args.length + 1
    args << "-newName" << resource[:new_name] if resource[:new_name] && (resource[:new_name] != resource[:name])
    args << "-description" << resource[:description] if @property_flush[:description]
    args << "-prcntFullThreshold" << resource[:percent_full_threshold] if @property_flush[:percent_full_threshold]
    args << "-autoTiering" << resource[:auto_tiering] if @property_flush[:auto_tiering]
    args << "-fastcache" << (resource[:ensure_fastcache] == :true ? "on" : "off") if @property_flush[:ensure_fastcache]
    args << "-snapPoolFullThresholdEnabled" << (resource[:snappool_fullthreshold] == :enabled ? "on" : "off") if @property_flush[:snappool_fullthreshold]
    args << "-snapPoolFullHWM" << resource[:snappool_hwm] if @property_flush[:snappool_hwm]
    args << "-snapPoolFullLWM" << resource[:snappool_lwm] if @property_flush[:snappool_lwm]
    args << "-snapSpaceUsedThresholdEnabled" << (resource[:snapspace_threshold] == :enabled ? "on" : "off") if @property_flush[:snapspace_threshold]
    args << "-snapSpaceUsedHWM" << resource[:snapspace_hwm] if @property_flush[:snapspace_hwm]
    args << "-snapSpaceUsedLWM" << resource[:snapspace_lwm] if @property_flush[:snapspace_lwm]

    args << "-o"
    if args.length > origin_length
      run(args)
      resource[:name] = resource[:new_name] if resource[:new_name]
    end
  end

  def create_storagepool
    create_pool = ["storagepool", "-create", "-name", resource[:name], "-disks", *resource[:disks]]
    create_pool << "-rtype" << resource[:raid_type] if resource[:raid_type]
    create_pool << "-rdrivecount" << resource[:rdrive_count] if resource[:rdrive_count]
    create_pool << "-description" << resource[:description] if resource[:description]
    create_pool << "-prcntFullThreshold" << resource[:percent_full_threshold] if resource[:percent_full_threshold]
    create_pool << "-skipRules" if resource[:skip_rules] == :true
    create_pool << "-autoTiering" << resource[:auto_tiering] if resource[:auto_tiering]
    create_pool << "-fastcache" << "on" if resource[:ensure_fastcache] == :true
    create_pool << "-fastcache" << "off" if resource[:ensure_fastcache] == :false
    create_pool << "--snapPoolFullThresholdEnabled" << "on" if resource[:snappool_fullthreshold] == :enabled
    create_pool << "--snapPoolFullThresholdEnabled" << "off" if resource[:snappool_fullthreshold] == :disabled
    create_pool << "-snapPoolFullHWM" << resource[:snappool_hwm] if resource[:snappool_hwm]
    create_pool << "-snapPoolFullLWM" << resource[:snappool_lwm] if resource[:snappool_lwm]
    create_pool << "-snapSpaceUsedThresholdEnabled" << "on" if resource[:snapspace_threshold] == :enabled
    create_pool << "-snapSpaceUsedThresholdEnabled" << "off" if resource[:snapspace_threshold] == :disabled
    create_pool << "-snapSpaceUsedHWM" << resource[:snapspace_hwm] if resource[:snapspace_hwm]
    create_pool << "-snapSpaceUsedLWM" << resource[:snapspace_lwm] if resource[:snapspace_lwm]
    create_pool << "-initialverify" << "yes" if resource[:initialverify] == :true
    create_pool << "-initialverify" << "no" if resource[:initialverify] == :false

    run(create_pool)
    @property_hash[:ensure] = :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def flush
    # destroy
    if @property_flush[:ensure] == :absent
      # destroy lun first
      @property_hash[:luns].each do |lun|
        args = ["lun", "-destroy", "-l", lun, "-o"]
        run args
      end
      run(["storagepool", "-destroy", "-name", resource[:name], "-o"])
      @property_hash[:ensure] = :absent
      return
    end

    if exists?
      set_storagepool
    else
      create_storagepool
    end
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def exists?
    current_properties[:ensure] == :present
  end
end
