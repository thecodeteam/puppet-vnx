begin
  require 'puppet_x/puppetlabs/transport/emc_vnx'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  puts "MODULE LIB IS #{module_lib}"
  require File.join module_lib, 'puppet_x/puppetlabs/transport/emc_vnx'
end

Puppet::Type.type(:vnx_lun).provide(:vnx_lun) do
  include PuppetX::Puppetlabs::Transport::EMCVNX

  desc "Manage LUNs for VNX."

  mk_resource_property_methods

  def initialize *args
    super
    @property_flush = {}
  end

  def get_current_properties
    lun_info = run(["lun", "-list", "-name", resource[:name]])
    self.class.get_lun_properties lun_info
  end

  def self.get_lun_properties lun_info
    lun = {}
    lun_info.split("\n").each do |line|
      if (pattern = "LOGICAL UNIT NUMBER") && line.start_with?(pattern)
        lun[:lun_number] = line.sub(pattern, "").strip.to_i
        next
      end

      if (pattern = "Name:") && line.start_with?(pattern)
        lun[:name] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "UID:") && line.start_with?(pattern)
        lun[:uid] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Current Owner:") && line.start_with?(pattern)
        owner = line.sub(pattern, "").strip
        owner = if owner == "SP A"
          :a
        elsif owner == "SP B"
          :b
        else
          raise "parse error, at: #{pattern}"
        end
        lun[:current_owner] = owner
        next
      end

      if (pattern = "Default Owner:") && line.start_with?(pattern)
        owner = line.sub(pattern, "").strip
        owner = if owner == "SP A"
          :a
        elsif owner == "SP B"
          :b
        else
          raise "parse error, at: #{pattern}"
        end
        lun[:default_owner] = owner
        next
      end

      if (pattern = "Allocation Owner:") && line.start_with?(pattern)
        owner = line.sub(pattern, "").strip
        owner = if owner == "SP A"
          :a
        elsif owner == "SP B"
          :b
        else
          raise "parse error, at: #{pattern}"
        end
        lun[:allocation_owner] = owner
        next
      end

      if (pattern = "User Capacity (Blocks):") && line.start_with?(pattern)
        lun[:user_capacity_blocks] = line.sub(pattern, "").strip.to_i
        next
      end

      if (pattern = /\AUser Capacity \((\w+)\):(.+)/) && line =~ pattern
        lun[:capacity] = $2.strip.to_i
        sq = $1.downcase
        lun[:size_qual] = [:gb, :tb, :mb, :bc].find{|v| sq.include? v.to_s}
        next
      end

      if (pattern = "Consumed Capacity (Blocks):") && line.start_with?(pattern)
        lun[:consumed_capacity_blocks] = line.sub(pattern, "").strip.to_i
        next
      end

      if (pattern = /\AConsumed Capacity \((\w+)\):(.+)/) && line =~ pattern
        lun[:consumed_capacity] = $2.strip.to_f
        next
      end

      if (pattern = "Pool Name:") && line.start_with?(pattern)
        lun[:pool_name] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Offset:") && line.start_with?(pattern)
        lun[:offset] = line.sub(pattern, "").strip.to_i
        next
      end

      if (pattern = "Auto-Assign Enabled:") && line.start_with?(pattern)
        lun[:auto_assign] = (line.sub(pattern, "").strip == "DISABLED" ? :false : :true)
        next
      end

      if (pattern = "Raid Type:") && line.start_with?(pattern)
        lun[:raid_type] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Is Pool LUN:") && line.start_with?(pattern)
        lun[:is_pool_lun] = (line.sub(pattern, "").strip == "Yes" ? :true : :false)
        next
      end

      if (pattern = "Is Thin LUN:") && line.start_with?(pattern)
        lun[:is_thin_lun] = (line.sub(pattern, "").strip == "Yes" ? :true : :false)
        lun[:type] = (lun[:is_thin_lun] == :true ? :thin : :nonthin)
        next
      end

      if (pattern = "Tiering Policy:") && line.start_with?(pattern)
        result = line.sub(pattern, "").strip.downcase
        result = if result.include? "auto"
                    :auto_tier
                  elsif result.include? "highest"
                    :highest_available
                  elsif result.include? "lowest"
                    :lowest_available
                  else
                    :no_movement
                  end
        lun[:tiering_policy] = result
        next
      end

      if (pattern = "Initial Tier:") && line.start_with?(pattern)
        result = line.sub(pattern, "").strip.downcase
        result = if result.include? "highest"
                    :highest_available
                  elsif result.include? "lowest"
                    :lowest_available
                  else
                    :optimize_pool
                  end
        lun[:initial_tier] = result
        next
      end
    end
    lun[:ensure] = :present
    lun
  end

  # def self.instances
  #   lun_instances = []
  #   luns_info = run ["lun", "-list"]
  #   luns_info.split("\n\n").each do |lun_info|
  #     lun = get_lun_properties lun_info
  #     lun_instances << new(lun)
  #   end
  #   lun_instances
  # end

  # def self.prefetch(resources)
  #   instances.each do |prov|
  #     if resource = resources[prov.name]
  #       resource.provider = prov
  #     end
  #   end
  # end

  # assume exists should be first called
  def exists?
    current_properties[:ensure] == :present
  end

  def set_lun
    # expand
    args = ["lun", "-expand", "-name", resource[:name]]
    origin_length = args.length
    args << "-capacity" << resource[:capacity] if @property_flush[:capacity]
    args << "-sq" << resource[:size_qual] if @property_flush[:size_qual]
    args << "-ignoreThresholds" if (resource[:ignore_thresholds] == :true)
    args << "-o"
    run(args) if args.length > origin_length + 1

    # modify
    args = ["lun", "-modify", "-name", resource[:name]]
    origin_length = args.length
    args << "-aa" << (resource[:auto_assign] == :true ? 1 : 0) if @property_flush[:auto_assign]
    args << "-newName" << resource[:new_name] if @property_flush[:new_name] && (@property_flush[:new_name] != resource[:name])
    args << "-sp" << resource[:default_owner].to_s.upcase if @property_flush[:default_owner]
    args << "-tieringPolicy" << (case resource[:tiering_policy]
    when :no_movement then "noMovement"
    when :auto_tier then "autoTier"
    when :highest_available then "highestAvailable"
    when :highest_available then "lowestAvailable"
    end) if @property_flush[:tiering_policy]

    args << "-initialTier" << (case resource[:initial_tier]
    when :optimize_pool then "optimizePool"
    when :highest_available then "highestAvailable"
    when :lowest_available then "lowestAvailable"
    end) if @property_flush[:initial_tier]

    args << "-allowSnapAutoDelete" << (resource[:allow_snap_auto_delete] == :true ? "yes" : "no") if @property_flush[:allow_snap_auto_delete]
    args << "-allowInbandSnapAttach" << (resource[:allow_inband_snap_attach] == :true ? "yes" : "no") if @property_flush[:allow_inband_snap_attach]
    if @property_flush[:allocation_policy]
      raise ArgumentError, "allocation_policy must be automatic" if resource[:allocation_policy] != :automatic
      args << "-allocationPolicy" << "automatic"
    end

    args << "-o"
    run(args) if args.length > origin_length + 1
  end

  def create_lun
    args = ['lun', '-create']
    if resource[:type] == :snap
      args << "-type" << "Snap"
      args << "-primaryLun" << resource[:primary_lun_number] if resource[:primary_lun_number]
      args << "-primaryLunName" << resource[:primary_lun_name] if resource[:primary_lun_name]
      args << "-sp" << resource[:default_owner].to_s.upcase if resource[:default_owner]
      args << "-l" << resource[:lun_number] if resource[:lun_number]
      args << "-name" << resource[:name] if resource[:name]
      args << "-allowSnapAutoDelete" << (resource[:allow_snap_auto_delete] == :true ? "yes" : "no") if resource[:allow_snap_auto_delete]
      args << "-allowInbandSnapAttach" << (resource[:allow_inband_snap_attach] == :true ? "yes" : "no") if resource[:allow_inband_snap_attach]
    else
      args << "-type" << (resource[:type] == :thin ? 'Thin' : 'NonThin') if resource[:type]
      args << "-capacity" << resource[:capacity] if resource[:capacity]
      args << "-poolId" << resource[:pool_id] if resource[:pool_id]
      args << "-poolName" << resource[:pool_name] if resource[:pool_name]
      args << "-sp" << resource[:default_owner].to_s.upcase if resource[:default_owner]
      args << "-aa" << (resource[:auto_assign] == :true ? 1 : 0) if resource[:auto_assign]
      args << "-l" << resource[:lun_number] if resource[:lun_number]
      args << "-name" << resource[:name]
      args << "-offset" << resource[:offset] if resource[:offset]
      args << "-tieringPolicy" << (case resource[:tiering_policy]
      when :no_movement then "noMovement"
      when :auto_tier then "autoTier"
      when :highest_available then "highestAvailable"
      when :lowest_available then "lowestAvailable"
      end) if resource[:tiering_policy]

      args << "-initialTier" << (case resource[:initial_tier]
      when :optimize_pool then "optimizePool"
      when :highest_available then "highestAvailable"
      when :lowest_available then "lowestAvailable"
      end) if resource[:initial_tier]

      args << "-allowSnapAutoDelete" << (resource[:allow_snap_auto_delete] == :true ? "yes" : "no") if resource[:allow_snap_auto_delete]
      args << "-ignoreThresholds" if (resource[:ignore_thresholds] == :true)
      args << "-allocationPolicy" << (resource[:allocation_policy] == :on_demand ? "onDemand" : "automatic") if resource[:allocation_policy]
    end

    run(args)
    @property_hash[:ensure] = :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    # destroy
    if @property_flush[:ensure] == :absent
      args = ["lun", "-destroy"]
      args << "-name" << resource[:name]
      args << "-o"
      run args
      @property_hash[:ensure] = :absent
      return
    end

    if exists?
      set_lun
    else
      create_lun
    end
  end
end
