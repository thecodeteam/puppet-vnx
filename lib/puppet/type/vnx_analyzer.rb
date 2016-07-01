Puppet::Type.newtype(:vnx_analyzer) do 
  @doc = "Manage VNX Analyzer settings."
  
  newparam(:name, :namevar => true) do
    desc "VNX Analyzer name, defaults to analyzer"
    defaultto :analyzer
  end

  newparam(:ensure_started) do
    desc "Controls starting and stopping the analyzer"
    defaultto :true
    newvalues(:true, :false)
  end

  newparam(:nar_interval) do
    desc "Polling interval for performance logging"
    validate do |value|
      fail("nar_interval must be an integer") unless value.is_a? Integer
      fail("Invalid value for nar_interval") unless value >= 60 and value <= 3600
     end
  end

  newparam(:rt_interval) do
    desc "Polling interval for real-time chart windows"
    validate do |value| 
      fail("rt_interval must be an integer") unless value.is_a? Integer
      fail("Invalid value for rt_interval") unless value >= 60 and value <= 3600
    end
  end
  
  newparam(:non_stop) do
    desc "Sets performance logging to non_stop"
    defaultto :false
    newvalues(:true, :false)
  end

  newparam(:log_period) do
    desc "Sets performance logging to run for 1-7 days"
    validate do |value|
      fail("Log period must be an integer") unless value.is_a? Integer
      fail("Invalid log_period value") unless value >=1 and value <= 7
    end
  end

  newparam(:periodic_logging) do
    desc "Creates archive files at periods of 156 samples"
    defaultto :false
    newvalues(:true, :false)
  end

  newparam(:default_logging) do
    desc "Sets logging to defaults"
    defaultto :false
    newvalues(:true, :false)
  end

  validate do
    fail("Non_stop and log_period cannot be specified together") if self[:log_period] and self[:non_stop]
  end


end
