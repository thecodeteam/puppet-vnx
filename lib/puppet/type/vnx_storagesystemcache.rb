Puppet::Type.newtype(:vnx_fastcache) do
  @doc = "Manage EMC VNX FAST cache settings."

  ensurable 

  newparam(:disks) do
    desc "The VNX disks to be used for FAST Cache.
      Disks must be specified in a comma separated list."
    isnamevar
    validate do |value|
      value.gsub!(/\s+/, "")
      value.split(",")
      value.each do |val|
        unless vnxdiskslist.include?(val)   
          raise ArgumentError, "Storage group names cannot exceed 64 characters." % value
        end
      end
    end
  end



  newparam(:mode) do
    desc "The VNX FAST Cache mode, can only be ro or rw."
    validate do |value|
      validmodes = ['ro', 'rw']
      unless validmodes.include?(value)
        raise ArgumentError, "%s mode is not a valid FAST cache mode." % value
      end
    end
  end

  newparam(:rtype) do
    desc "The VNX FAST Cache raid type, can only be disk or r_1."
    validate do |value|
      validraid = ['disk', 'r_1']
      unless validraid.include?(value)
        raise ArgumentError, "%s is not a valid RAID type for FAST cache." % value
      end
    end
  end

end
