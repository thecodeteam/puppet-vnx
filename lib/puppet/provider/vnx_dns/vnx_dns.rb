Puppet::Type.type(:vnx_dns).provide(:vnx_dns) do
  desc "Configure DNS settings for VNX."
  
  def self.instances
    dns_info = run(%w[networkadmin -dns -list]).split("\n")
    dns_info.each do |line|
      if line.include?("DNS Domain")
        domain = line.gsub("DNS Domain:", '').strip
      elsif line.include?("DNS Name Servers")
        name_servers = line.scan(/\d+\.\d+\.\d+\.\d+/)
      elsif line.include?("DNS Search List:")
        search_list = line.gsub("DNS Search List:", '').strip.split(' ')
      end
    end
    new dns_settings = { :name => domain,
                         :ensure => :present,
                         :name_servers => name_servers,
                         :search_list => search_list }
    dns_instances << new(dns_settings)
  end

  def self.prefetch(resources)
    dns = instances
    resources.keys.each do |name|
      if provider = dns.find{ |dnsname| dnsname.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists
    @property_hash[:ensure] == :present
  end
    
  def create
    set_dns = "-networkadmin", "-dns", "-set" resource[:name] 
    set_dns << "-nameserver" << resource[:name_servers] if resource [:name_servers]
    set_dns << "-searchlist" << resource[:search_list] if resource[:search_list]
    set_dns << "-o"
    run(set_dns)
    @property_hash[:ensure] = :present
  end

  def name_servers=(value)
    set_ns = "-networkadmin", "-dns", "-set", "-nameserver", value, "-o"
    run(set_ns)
  end

  def search_list=(value)
    set_sl = "-networkadmin", "-dns", "-set", resource[:search_list], "-o"
    run(set_sl)
  end

  def destroy
    # No method to destroy DNS settings so leave action blank
    @property_hash[:ensure] = :absent
  end

end

