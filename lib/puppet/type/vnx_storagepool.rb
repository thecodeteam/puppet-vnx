Puppet::Type.newtype(:vnx_storagepool) do
  @doc = "Manage EMC VNX storage pools."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The storage pool name."
    isnamevar
    validate do |value|
      fail("Storage group name cannot exceed 64 characters") unless value.length <= 64
    end
  end

  newproperty(:disks, :array_matching => :all) do
    desc "The disks to add to the storage pool."

    validate do |*value|
      fail ("Invalid format for disks") unless value.all?{|v| v =~ /\A\d+\_\d+\_\d+\z/}
    end

    def insync? is
      is.sort == should.sort
    end

  end

  
  newproperty(:raid_type) do
    desc "The RAID type for the pool."
    munge do |value|
      if %w[r_5 r_6 R_10].include? value
        value.to_sym
      else
        value
      end
    end
    newvalues(:r_5, :r_6, :r_10)
  end

  newparam(:rdrive_count) do
    desc "The RAID drive count used to create internal RAID groups"
  end

  newproperty(:description) do
    desc "The storage pool description"
    validate do |value|
      fail("Description must be between 0 and 255 characters") unless value.length > 0 and value.length <=255
    end
  end

  newproperty(:percent_full_threshold) do
    desc "The percent full before alerts are generated"
    validate do |value|
      fail("Non-integer value specified") unless value.is_a? Integer
      fail("Invalid percent value") unless value >=1 and value <=84
    end
  end

  newparam(:skip_rules) do
    desc "Allows skipping rule checking when creating pools"
    newvalues(:true, :false)
  end

  newparam(:auto_tiering) do
    desc "Sets the auto tiering schedule"
    newvalues(:manual, :scheduled)
  end

  newparam(:ensure_fastcache) do
    desc "Enables or disables FAST Cache for the pool"
    newvalues(:true, :false)
  end

  newparam(:snappool_fullthreshold) do
    desc "Enables or disables checking HWM for auto delete"
    munge do |value|
      if %w[enabled disabled].include? value.downcase
        values.downcase.to_sym
      else
        value
      end
    end
    newvalues(:enabled, :disabled)
  end

  newparam(:snappool_hwm) do
    desc "The pool full HWM that triggers auto delete"
    validate do |value|
      fail("Invalid value for Snap Pool Full HWM") unless value.is_a? Integer and value > 0 and value < 100
    end
  end

  newparam(:snappool_lwm) do
    desc "The pool full LWM that stops auto delete"
    validate do |value|
      fail("Invalid value for Snap Pool Full LWM") unless value.is_a? Integer and value > 0 and value < 100
    end
  end

  newparam(:snapspace_threshold) do
    desc "Check snapshot space for HWM for auto delete"
    newvalues(:enabled, :disabled)
  end

  newparam(:snapspace_hwm) do
    desc "Snapshot space used HWM that triggers auto delete"
    validate do |value|
      fail("Invalid value for Snap Space Used HWM") unless value.is_a? Integer and value > 0 and value < 100
    end
  end

  newparam(:snapspace_lwm) do
    desc "Snapshot space LWM which stops auto delete"
    validate do |value|
      fail("Invalid value for Snap Space Used LWM") unless value.is_a? Integer and value > 0 and value < 100
    end
  end

  newparam(:initialverify) do
    desc "Specify whether initial verify is run on pool creation or expansion"
    newvalues(:true, :false)
  end

  newproperty(:cancel_expand) do
    desc "cancel expand"

    defaultto :false
    newvalues(:true, :false)
  end

  newproperty(:new_name) do
    desc "The new storage pool name."

    validate do |value|
      fail("Storage group name cannot exceed 64 characters") unless value.length <= 64
    end
  end

  #=================================read-only values=====================

  newproperty(:pool_id) do
     validate do
      fail "pool_id is read-only"
    end
  end

  newproperty(:disk_type) do
    desc "Disk Type"

    validate do
      fail "disk_type is read-only"
    end
  end

  newproperty(:state) do
    desc "State"

    validate do
      fail "state is read-only"
    end
  end

  newproperty(:status) do
    desc "Status"

    validate do
      fail "status is read-only"
    end
  end

  newproperty(:current_operation) do
    desc "Current Operation"

    validate do
      fail "current_operation is read-only"
    end
  end

  newproperty(:current_operation_state) do
    desc "Current Operation State"

    validate do
      fail "current_operation_state is read-only"
    end
  end

  newproperty(:current_operation_status) do
    desc "Current Operation Status"

    validate do
      fail "current_operation_status is read-only"
    end
  end

  newproperty(:current_operation_percent_completed) do
    desc "Current Operation Status Completed"

    validate do
      fail "current_operation_percent_completed is read-only"
    end
  end

  newproperty(:raw_capacity_blocks) do
    desc "Raw Capacity (Blocks)"

    validate do
      fail "raw_capacity_blocks is read-only"
    end
  end

  newproperty(:raw_capacity_gbs) do
    desc "Raw Capacity (GBs)"

    validate do
      fail "raw_capacity_gbs is read-only"
    end
  end

  newproperty(:user_capacity_blocks) do
    desc "User Capacity (Blocks)"
    validate do
      fail "user_capacity_blocks is read-only"
    end
  end

  newproperty(:user_capacity_gbs) do
    desc "User Capacity (GBs)"
    validate do
      fail "user_capacity_gbs is read-only"
    end
  end

  newproperty(:consumed_capacity_blocks) do
    desc "Consumed Capacity (Blocks)"
    validate do
      fail "consumed_capacity_blocks is read-only"
    end
  end

  newproperty(:consumed_capacity_gbs) do
    desc "Consumed Capacity (GBs)"
    validate do
      fail "consumed_capacity_gbs is read-only"
    end
  end

  newproperty(:available_capacity_blocks) do
    desc "Available Capacity (Blocks)"
    validate do
      fail "available_capacity_blocks is read-only"
    end
  end

  newproperty(:available_capacity_gbs) do
    desc "Available Capacity (GBs)"
    validate do
      fail "available_capacity_gbs is read-only"
    end
  end

  newproperty(:percent_full) do
    desc "Percent Full"
    validate do
      fail "percent_full is read-only"
    end
  end

  newproperty(:total_subscribed_capacity_blocks) do
    desc "Total Subscribed Capacity (Blocks)"
    validate do
      fail "total_subscribed_capacity_blocks is read-only"
    end
  end

  newproperty(:total_subscribed_capacity_gbs) do
    desc "Total Subscribed Capacity (GBs)"
    validate do
      fail "total_subscribed_capacity_gbs is read-only"
    end
  end

  newproperty(:percent_subscribed) do
    desc "Percent Subscribed"
    validate do
      fail "percent_subscribed is read-only"
    end
  end

  newproperty(:oversubscribed_by_blocks) do
    desc "Oversubscribed by (Blocks)"
    validate do
      fail "oversubscribed_by_blocks is read-only"
    end
  end

  newproperty(:oversubscribed_by_gbs) do
    desc "Oversubscribed by (GBs)"
    validate do
      fail "oversubscribed_by_gbs is read-only"
    end
  end

  newproperty(:luns, :array_matching => :all) do
    desc "LUNs"

    validate do
      fail "luns is read-only"
    end
  end

end
