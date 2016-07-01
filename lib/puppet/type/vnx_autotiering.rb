Puppet::Type.newtype(:vnx_autotiering) do 
  @doc = "Manage EMC autotiering and autotiering schedule."
  
  newparam(:schedule, :namevar => true, :array_matching => :all) do
    desc "The days of the week for the scheduled VNX autotiering."
    validate do |value|
      validdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      fail("Invalid day for autotiering schedule") unless validdays.include?(value)
    end
  end

  newparam(:ensure_enabled) do
    desc "Controls the enabling and disabling of autotiering"
    defaultto :false
    newvalues(:false, :true)
  end

  newparam(:time) do
    desc "The time of day for VNX autotiering.
      Valid values are colon separated digits representing hour and time
      in the formate hh:mm or h:mm."
    validate do |value|
      fail("Invalid Time specificiation") unless value =~/^([01]?[0-9]|2[0-3]):[0-5][0-9]/
    end
  end
      
  newparam(:duration) do
    desc "The duration for a manual relocation."
    validate do |value|
      fail("Invalid duration") unless value =~/^([01]?[0-9]|2[0-3]):[0-5][0-9]/
    end
  end

  newparam(:relocation_rate) do
    desc "The rate for manual relocation; high, medium or low."
    defaultto :medium
    newvalues(:medium, :high, :low)
  end
    
  newparam(:poolname) do
    desc "The pool name for relocation. Specify pool name or 'all' to
          apply to all pools"
  end

  validate do 
    if self[:ensure_enabled] == :true
      fail("Must specify schedule for autotiering") unless self[:time] or self[:days] or self[:duration]
    end
  end
 
end 
