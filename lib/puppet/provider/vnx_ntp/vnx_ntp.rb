Puppet::Type.type(:vnx_ntp).provide(:vnx_ntp) do
  desc "Configure NTP settings for VNX."
  
  def self.instances
    ntp_info = run(%w[ntp -list -all]).split("\n")
    ntp_info.each do |line|
      if line.include?('start')
        running = line.gsub("start:", '').strip
      elsif line.include?('interval')
        interval = line.gsub("interval:", '').strip
      elsif line.include?('address')
        address = line.scan(/\d+\.\d+\.\d+\.\d+/).sort
      elsif line.include?('serverkey')
        server_keys = line.gsub("serverkey:", " ").split(" ")
      elsif line.include?('keyvalue')
        keyvalues = line.gsub("keyvalue:", " ").split(" ")
      end
    end
    new ntp_settings = { :ntp_servers => address,
                         :ensure => :present,
                         :interval => interval,
                         :ensure_running => running,
                         :server_key => server_keys,
                         :keyvalue => keyvalues }
    ntp_instances << new(ntp_settings)
  end

  def self.prefetch(resources)
    ntp = instances
    resources.keys.each do |name|
      if provider = ntp.find{ |ntpname| ntpname.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists
    @property_hash[:ensure] == :present
  end
    
  def create
    set_ntp = "-set", "-start", resource[:ensure_running], "-servers", resource[:ntp_servers]
    set_ntp << "-serverkey", resource[:server_key], "-keyvalue", resource[:keyvalue] if resource[:server_key]
    run(set_ntp)
    @property_hash[:ensure] = :present
  end

  def destroy
    run("ntp", "-set", "-start", "no")
    @property_hash[:ensure] = :absent
  end

end

