begin
  require 'puppet_x/puppetlabs/transport/emc_vnx'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  puts "MODULE LIB IS #{module_lib}"
  require File.join module_lib, 'puppet_x/puppetlabs/transport/emc_vnx'
end

Puppet::Type.type(:vnx_storagegroup).provide(:vnx_storagegroup) do
  include PuppetX::Puppetlabs::Transport::EMCVNX

  desc "Manages VNX Storage Groups."

  mk_resource_property_methods

  def initialize *args
    super
    @property_flush = {}
  end

  def addhlu hlu, alu
    # begin
    #   # check alu presences
    #   run(["lun", "-list", "-l", alu])
    # rescue
    #   run ["lun", "-create", "-l", alu]
    # end
    args = ["storagegroup", "-addhlu", "-gname", resource[:sg_name], "-hlu", hlu, "-alu", alu]
#    puts "#{args}"
    run args
  end

  def removehlu hlu
    args = ["storagegroup", "-removehlu", "-gname", resource[:sg_name], "-hlu", hlu, "-o"]
    run args
  end

  def setpath
    args = ["storagegroup", "-setpath", "-o"]
    args << "-gname" << resource[:sg_name] if resource[:sg_name]
    args << "-hbauid" << resource[:hbauid]
    args << "-sp" << resource[:sp]
    args << "-spport" << resource[:sp_port]
    args << "-spvport" << resource[:sp_vport] if resource[:sp_vport]
    args << "-type" << resource[:initiator_type] if resource[:initiator_type]
    args << "-ip" << resource[:ip_address] if resource[:ip_address]
    args << "-host" << resource[:hostname] if resource[:hostname]
    args << "-failovermode" << resource[:failover_mode] if resource[:failover_mode]
    args << "-arraycommpath" << resource[:array_commpath] if resource[:array_commpath]
    args << "-unitserialnumber" << resource[:unit_serialnumber] if resource[:unit_serialnumber]
    run args
#    @property_hash[:ensure] = :present
  end

  def addhost
    args = ["storagegroup", "-connecthost", "-host", resource[:host_name], "-gname", resource[:sg_name], "-o"]
    run args
  end

  def get_current_properties
    sg = run(["storagegroup", "-list", "-gname", resource[:sg_name]])
    self.class.get_storagegroup_properties sg
  end

  def self.get_storagegroup_properties sg
      line_values = sg.split /\n+/
      line_values.shift while line_values.first.empty?
      storage_group = {}
      while line_value = line_values.shift
        if line_value.start_with?('Storage Group Name:')
          storage_group[:sg_name] = line_value[(line_value.index(":") + 1)..-1].strip
          next
        end

        if line_value.start_with?('Storage Group UID:')
          storage_group[:uid] = line_value[(line_value.index(":") + 1)..-1].strip
          next
        end

        if line_value.start_with?('Shareable:')
          shareable = line_value[(line_value.index(":") + 1)..-1].strip
          storage_group[:shareable] = (shareable == "YES" ? :true : :false)
          next
        end

        if line_value.start_with?('HBA/SP Pairs:')
          if line_values.first.start_with? "  HBA UID"
            line_values.shift
            if line_values.first.start_with? "  -----"
              line_values.shift
              pairs = []
              while line_values.first.start_with? "  "
                hba_uid, sp_name, sp_port = line_values.first.strip.split(/\s{2,}/)
                pairs << ({:hba_uid => hba_uid, :sp_name => (sp_name == "SP A" ? :a : :b), :sp_port => sp_port.to_i})
                line_values.shift
              end
              storage_group[:HBAs] = pairs
            end
          end
        end

        if line_value.start_with?('HLU/ALU Pairs:')
          if line_values.first.start_with? "  HLU Number"
            line_values.shift
            if line_values.first.start_with? "  -----"
              line_values.shift
              pairs = []
              while line_values.first.start_with? "  "
                hlu, alu = line_values.first.strip.split.map{|v| v.to_i}
                pairs << ({'hlu' => hlu, 'alu' => alu})
                line_values.shift
              end
              storage_group[:luns] = pairs
            end
          end
        end

      end
      storage_group[:ensure] = :present
      storage_group
  end

  # def self.instances
  #   storage_groups=[]
  #   storage_group_info = run ["storagegroup", "-list"]
  #   storage_group_info.split("Storage Group Name:").each do |sg|
  #     line_values = sg.split /\n+/
  #     next if line_values.empty? #skip blank line
  #     line_values.shift while line_values.first.empty?
  #     storage_group = {:name => line_values.shift.strip}
  #     while line_value = line_values.shift
  #       if line_value.start_with?('Storage Group UID:')
  #         storage_group[:uid] = line_value[(line_value.index(":") + 1)..-1].strip
  #         next
  #       end
  #
  #       if line_value.start_with?('Shareable:')
  #         shareable = line_value[(line_value.index(":") + 1)..-1].strip
  #         storage_group[:shareable] = (shareable == "YES" ? :true : :false)
  #         next
  #       end
  #
  #       if line_value.start_with?('HBA/SP Pairs:')
  #         if line_values.first.start_with? "  HBA UID"
  #           line_values.shift
  #           if line_values.first.start_with? "  -----"
  #             line_values.shift
  #             pairs = []
  #             while line_values.first.start_with? "  "
  #               hba_uid, sp_name, sp_port = line_values.first.strip.split(/\s{2,}/)
  #               pairs << ({:hba_uid => hba_uid, :sp_name => (sp_name == "SP A" ? :a : :b), :sp_port => sp_port.to_i})
  #               line_values.shift
  #             end
  #             storage_group[:HBAs] = pairs
  #           end
  #         end
  #       end
  #
  #       if line_value.start_with?('HLU/ALU Pairs:')
  #         if line_values.first.start_with? "  HLU Number"
  #           line_values.shift
  #           if line_values.first.start_with? "  -----"
  #             line_values.shift
  #             pairs = []
  #             while line_values.first.start_with? "  "
  #               hlu, alu = line_values.first.strip.split.map{|v| v.to_i}
  #               pairs << ({'hlu' => hlu, 'alu' => alu})
  #               line_values.shift
  #             end
  #             storage_group[:luns] = pairs
  #           end
  #         end
  #       end
  #
  #     end
  #     storage_group[:ensure] = :present
  #     storage_groups << new(storage_group)
  #   end
  #   storage_groups
  # end
  #
  # def self.prefetch(resources)
  #   vnx_storagegroup = instances
  #   resources.keys.each do |name|
  #     if provider = vnx_storagegroup.find{ |storagegroup| storagegroup.name == name }
  #       resources[name].provider = provider
  #     end
  #   end
  # end

  def create_storagegroup
    run(["storagegroup", "-create", "-gname", resource[:sg_name]])
    set_storagegroup
    @property_hash[:ensure] = :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def set_storagegroup
    if @property_flush[:luns]
      pairs = resource[:luns]
      should_pairs = if pairs.nil? || pairs == :absent
                        []
                      else
                        pairs.map{|pair| pair.values_at('hlu', 'alu').map &:to_s}.sort
                      end
      current_properties = get_current_properties
      current_pairs = current_properties[:luns]
      is_pairs = if current_pairs.nil? || current_pairs == :absent
                    []
                  else
                    current_pairs.map{|pair| pair.values_at('hlu', 'alu').map &:to_s}.sort
                  end
#      remove_pairs = is_pairs - should_pairs
#      remove_pairs.each{|hlu, alu| removehlu hlu}
      add_pairs = should_pairs - is_pairs
      add_pairs.each{|hlu, alu| addhlu hlu, alu}
    end

    #set the initiator path
    if @property_flush[:hbauid]
        #hostname = resource[:hbauid]
#        puts "tohdat debug: property_flush #{@property_flush[:hbauid]}"
#        puts "tohdat debug: #{@property_flush[:addonly]}"
        if @property_flush[:setpathonly] == :true
            args = ["storagegroup", "-setpath", "-o"]
            args << "-gname" << resource[:sg_name] if resource[:sg_name]
            args << "-hbauid" << resource[:hbauid]
            args << "-sp" << resource[:sp]
            args << "-spport" << resource[:sp_port]
            args << "-spvport" << resource[:sp_vport] if resource[:sp_vport]
            args << "-type" << resource[:initiator_type] if resource[:initiator_type]
            args << "-ip" << resource[:ip_address] if resource[:ip_address]
            args << "-host" << resource[:hostname] if resource[:hostname]
            args << "-failovermode" << resource[:failover_mode] if resource[:failover_mode]
            args << "-arraycommpath" << resource[:array_commpath] if resource[:array_commpath]
            args << "-unitserialnumber" << resource[:unit_serialnumber] if resource[:unit_serialnumber]
#            puts "tohdat debug: running args...#{args}"
            run args
        end
    end

    #change the hosts
    if @property_flush[:host_name]
        #hostname = resource[:host_name]
        puts "wzz debug: property_flush #{@property_flush[:host_name]}"
        puts "wzz debug: #{@property_flush[:addonly]}"
        if @property_flush[:addonly] == :true
            args = ["storagegroup", "-connecthost", "-host", resource[:host_name], "-gname", resource[:sg_name], "-o"]
            puts "wzz debug: running args...#{args}"
            run args
        end
    end



    #change the storage group name
    if @property_flush[:new_name] && (@property_flush[:new_name] != resource[:sg_name])
      args = ["storagegroup", "-chgname", "-gname", resource[:sg_name], "-newgname", @property_flush[:new_name], "-o"]
      run args
      resource[:sg_name] = @property_flush[:new_name]
    end
  end

  def flush
    # destroy
    if @property_flush[:ensure] == :absent
      run(["storagegroup", "-destroy", "-gname", resource[:sg_name], "-o"])
      @property_hash[:ensure] = :absent
      return
    end

    if exists?
      set_storagegroup
    else
      create_storagegroup
    end
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def exists?
    current_properties[:ensure] == :present
  end
end
