Puppet::Type.newtype(:vnx_fastcache) do
  @doc = "Manage EMC VNX FAST cache settings."

  #ensurable

  newparam(:cache_mode) do
    desc "Cache mode, can be rw or ro"
      newvalues(:ro, :rw)
  end

  newparam(:raid_type) do
    desc "The FAST Cache raid type"
    defaultto :r_1
    newvalues(:r_1)
  end


  newproperty(:disks, :namevar => true, :array_matching => :all) do
    desc "The VNX disks to be used for FAST Cache.
      Disks must be specified in an array."
    # Build up list of disks available for FAST Cache
    validate do |value|
      fail ("Invalid format for disks") unless value =~/(^\d{1})[_](\d{1})[_](\d{1})$/
    end
  end

  validate do 
    if self[:disks] or self[:raid_type] or self[:cache_mode]
       unless self[:disks] and self[:raid_type] and self[:cache_mode]
         fail("Disks, RAID Type, and Cache Mode are required to enable FAST Cache")
       end
    end
  end

end
