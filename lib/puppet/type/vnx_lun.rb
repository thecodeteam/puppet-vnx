Puppet::Type.newtype(:vnx_lun) do
  @doc = "Manage EMC VNX LUNs."

  ensurable

  newproperty(:lun_number) do
    desc "The LUN Id."
  end

  newparam(:name, :namevar => true) do
    desc "The LUN name"
    validate do |value|
      fail("LUN name cannot exceed 64 characters") unless value.length <= 64
    end
  end

  newparam(:primary_lun_number) do
    desc "The primary LUN number"
  end

  newparam(:primary_lun_name) do
    desc "The primary LUN number"
  end

  newproperty(:new_name) do
    desc "The LUN new name"

    validate do |value|
      fail("LUN name cannot exceed 64 characters") unless value.length <= 64
    end
  end

  newparam(:type) do
    desc "LUN type, THIN or Thick. Unchangeable once created."
    newvalues(:thin, :nonthin, :snap)
  end

  newproperty(:capacity) do
    desc "The LUN capacity"
    munge do |value|
      value.to_i
    end
  end

  newproperty(:size_qual) do
    desc "Size qualifier for the LUN capacity"
    newvalues(:gb, :tb, :mb, :bc)
  end

  newproperty(:pool_name) do
    desc "Storage pool the LUN will belong to. Unchangeable once created."
  end

  newproperty(:pool_id) do
    desc "Storage pool the LUN will belong to. Unchangeable once created."
  end

  newproperty(:auto_assign) do
    desc "Specifies whether to use auto assign for the LUN. Unchangeable once created."
    newvalues(:true, :false)
  end

  newproperty(:offset) do
    desc "The LUN offset. Unchangeable once created."

    munge do |value|
      value.to_i
    end
  end

  newproperty(:tiering_policy) do
    desc "The LUN auto-tiering policy"
    newvalues(:no_movement, :auto_tier, :highest_available, :lowest_available)
  end

  newproperty(:initial_tier) do
    desc "The initial tier preference"
    newvalues(:optimize_pool, :lowest_available, :highest_available)
  end

  newproperty(:allow_snap_auto_delete) do
    desc "Allow deleting snap automatically when lun is deleted"
    newvalues(:true, :false)
  end

  newproperty(:allow_inband_snap_attach) do
    desc "Allow Inband Snap Attach"
  end

  newproperty(:ignore_thresholds) do
    desc "Forces the non-snap LUN to be created, ignoring possible threshold related error"
    newvalues(:true, :false)
  end

  newproperty(:allocation_policy) do
    desc "The allocation policy on the pool LUN."
    newvalues(:on_demand, :automatic)
  end

  newproperty(:default_owner) do
    desc "Default Service Port the LUN belong to"

    newvalues(:a, :b)
  end

  #============Read Only Properties=============#
  newproperty(:uid) do
    desc "UID"

    validate do
      fail "uid is read-only"
    end
  end

  newproperty(:current_owner) do
    desc "Current Service Port the LUN belong to"

    validate do
      fail "current_owner is read-only"
    end
  end

  newproperty(:allocation_owner) do
    desc "Allocation Service Port the LUN belong to"

    validate do
      fail "allocation_owner is read-only"
    end
  end

  newproperty(:user_capacity_blocks) do
    desc "User Capacity (Blocks)"

    validate do
      fail "user_capacity_blocks is read-only"
    end
  end

  newproperty(:consumed_capacity_blocks) do
    desc "Consumed Capacity (Blocks)"

    validate do
      fail "consumed_capacity_blocks is read-only"
    end
  end

  newproperty(:consumed_capacity) do
    desc "Consumed Capacity"

    validate do
      fail "consumed_capacity is read-only"
    end
  end

  newproperty(:raid_type) do
    desc "Raid Type of the LUN"

    validate do
      fail "Raid type is read-only"
    end
  end

  newproperty(:is_pool_lun) do
    newvalues(:true, :false)

    validate do
      fail "is_pool_lun is read-only"
    end
  end

  newproperty(:is_thin_lun) do
    newvalues(:true, :false)

    validate do
      fail "is_thin_lun is read-only"
    end
  end
end
