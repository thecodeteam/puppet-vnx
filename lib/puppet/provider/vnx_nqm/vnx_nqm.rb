begin
  require 'puppet_x/puppetlabs/transport/emc_vnx'
rescue LoadError => e
  require 'pathname' # WORK_AROUND #14073 and #7788
  module_lib = Pathname.new(__FILE__).parent.parent.parent
  puts "MODULE LIB IS #{module_lib}"
  require File.join module_lib, 'puppet_x/puppetlabs/transport/emc_vnx'
end

Puppet::Type.type(:vnx_nqm).provide(:vnx_nqm) do
  include PuppetX::Puppetlabs::Transport::EMCVNX

  desc "Set QoS for LUNs for VNX."
  
  $ioClass = [] 
  $iNumIOClass = 0
  
  mk_resource_property_methods

  def initialize *args
    super
    @property_flush = {}
  end

  def get_current_properties
    nqm_info = run(["nqm", "-ioclass", "-list", "-name", resource[:ioclass]])
    self.class.get_nqm_properties nqm_info
  end

  def self.get_nqm_properties nqm_info
    nqm = {}
    nqm_info.split("\n").each do |line|

      if (pattern = "Name:") && line.start_with?(pattern)
        nqm[:ioclass] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Current State:") && line.start_with?(pattern)
        nqm[:current_state] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Status:") && line.start_with?(pattern)
        nqm[:status] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Number of LUN(s):") && line.start_with?(pattern)
        nqm[:number_of_luns] = line.sub(pattern, "").strip.to_i
        next
      end

      if (pattern = "LUN Number:") && line.start_with?(pattern)
        nqm[:lun_number] = line.sub(pattern, "").strip.to_i
        next
      end

      if (pattern = "LUN Name:") && line.start_with?(pattern)
        nqm[:lun_name] = line.sub(pattern, "").strip.to_i
        next
      end

      if (pattern = "LUN WWN:") && line.start_with?(pattern)
        nqm[:lun_wwn] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "RAID Type:") && line.start_with?(pattern)
        nqm[:raid_type] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "IO Type:") && line.start_with?(pattern)
        nqm[:io_type] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "IO Size Range:") && line.start_with?(pattern)
        nqm[:io_size_range] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Control Method:") && line.start_with?(pattern)
        nqm[:control_method] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Metric Type:") && line.start_with?(pattern)
        nqm[:metric_type] = line.sub(pattern, "").strip
        next
      end

      if (pattern = "Goal Value:") && line.start_with?(pattern)
        nqm[:goal_value] = line.sub(pattern, "").strip
        next
      end

    end
    nqm[:ensure] = :present
    nqm
  end

  # assume exists should be first called
  def exists?
    current_properties[:ensure] == :present
  end

  def create_ioclass
    args = ['nqm', '-ioclass', '-create', '-name', resource[:ioclass]]
    args << "-iotype" << resource[:io_type]
    args << "-anyio" if resource[:anyio]
    args << "-luns" << resource[:lun_number]
    args << "-ctrlmethod" << resource[:control_method]
    args << "-gmetric" << resource[:metric_type]
    args << "-gval" << resource[:goal_value]
    run(args)
    $ioClass[$iNumIOClass]="#{resource[:ioclass]}"
    $iNumIOClass=$iNumIOClass+1

   # out_ioclasses = `echo #{resource[:ioclass]} >> /tmp/#{resource[:policy_name]}.txt`
   # out_ioclasses
    @property_hash[:ensure] = :present
  end

  def modify_ioclass
    args = ['nqm', '-ioclass', '-modify', '-name', resource[:ioclass]]
    origin_length = args.length
    args << "-iotype" << resource[:io_type]
    args << "-anyio" if resource[:anyio]
    args << "-luns" << resource[:lun_number]
    args << "-ctrlmethod" << resource[:control_method]
    args << "-gmetric" << resource[:metric_type]
    args << "-gval" << resource[:goal_value]
    run(args)
    $ioClass[$iNumIOClass]="#{resource[:ioclass]}"
    $iNumIOClass=$iNumIOClass+1
    @property_hash[:ensure] = :present
  end

 # def get_file_as_string(filename)
 #   data = ''
 #   f = File.open(filename, "r") 
 #   f.each_line do |line|
 #     data += line
 #   end
 #   return data
 # end

  def create_policy
  #  f_name = "/tmp/" + resource[:policy_name] + ".txt"
  #  ioclass_list = get_file_as_string(f_name)
  #  ioclass_list = ioclass_list.gsub("\n", ' ')
    args = ['nqm', '-policy', '-create', '-name', resource[:policy_name], '-ioclasses', *$ioClass]
    args << "-failaction" << resource[:fail_action]
    run(args)
    @property_hash[:ensure] = :present
  end

  def modify_policy
    args = ['nqm', '-policy', '-modify', '-name', resource[:policy_name]]
    args << "-ioclasses" << resource[:ioclass]
    args << "-failaction" << resource[:fail_action]
    run(args)
    @property_hash[:ensure] = :present
  end

  def run_policy
    args = ['nqm', '-run', resource[:policy_name]]
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
      args = ["nqm", "-ioclass", "-destroy"]
      args << "-name" << resource[:ioclass]
      args << "-o"
      run args
      @property_hash[:ensure] = :absent
      return
    end

    if exists?
      modify_ioclass
    else
      if resource[:ioclass]
        create_ioclass
      else
	create_policy
      end

    end
  end
end
