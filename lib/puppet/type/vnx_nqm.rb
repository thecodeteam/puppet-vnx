Puppet::Type.newtype(:vnx_nqm) do
  @doc = "Manage EMC VNX LUNs."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The IOclass name"
    validate do |value|
      fail("IOclass name cannot exceed 64 characters") unless value.length <= 64
    end
  end

  newproperty(:ioclass) do
    desc "The IOclass."
  end

  newproperty(:current_state) do
    desc "The current_state."
  end

  newproperty(:status) do
    desc "The status."
  end

  newproperty(:number_of_luns) do
    desc "The number_of_luns."
  end

  newproperty(:lun_number) do
    desc "The LUN Id."
  end

  newparam(:lun_name) do
    desc "The LUN name"
    validate do |value|
      fail("LUN name cannot exceed 64 characters") unless value.length <= 64
    end
  end

  newproperty(:lun_wwn) do
    desc "The LUN WWN."
  end

  newproperty(:raid_type) do
    desc "The raid_type."
  end

  newproperty(:io_type) do
    desc "The io_type."
  end

  newproperty(:io_size_range) do
    desc "The io_size_range."
  end

  newproperty(:control_method) do
    desc "The control_method."
  end

  newproperty(:metric_type) do
    desc "The metric_type."
  end

  newproperty(:goal_value) do
    desc "The goal_value."
  end

  newproperty(:anyio) do
    desc "The anyio."
  end

  newproperty(:policy_name) do
    desc "The policy name."
  end

  newproperty(:fail_action) do
    desc "The fail_action."
  end


  #============Read Only Properties=============#
end
