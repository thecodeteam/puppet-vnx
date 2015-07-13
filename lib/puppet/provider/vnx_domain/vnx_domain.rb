Puppet::Type.type(:vnx_domain).provide(:vnx_domain) do
  desc "Configure NTP settings for VNX."
  
  def self.instances
    domain_instances = []
    domain_info = run(%w[domain -list]).split("\n")
    domain_info.each do |line|
      master = false
      if line.include?('IP Address:')
        ip_address = line.scan(/\d+\.\d+\.\d+\.\d+/)
        master = true if line.include?('Master')
      end
      new vnx_domains = { :name => ip_address,
                          :ensure => :present,
                          :master => master, }

      domain_instances << new(vnx_domains)
    end
    domain_instances
  end
  

  def self.prefetch(resources)
    domain = instances
    resources.keys.each do |name|
      if provider = domain.find{ |domainname| domainname.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists
    @property_hash[:ensure] == :present
  end
    
  def create
    create_domain = "domain", "-add", resource[:name]
    create_domain << "-olduser", resource[:old_user], "-oldpassword" resource[:old_password], "-oldscope", resource[:old_scope], "-o" if resource[:old_user]
    run(create_domain)
    @property_hash[:ensure] = :present
  end

  def destroy
    run("domain", "-remove", resource[:name], "-o")
   @property_hash[:ensure] = :absent
  end
  
  def unitialize=(value)
    run("domain", "-uninitialize", resource[:name], "-o") if unitialize == :true
  end

  def master
    @property_hash[:master]
  end
  
  def master=(value)
    if value == :true and master_defined
      raise Puppet::Error, "Master already set in domain"
    else
      run("domain", "-setmaster", resource[:name], "-o") if value == :true
    end
  end

  def master_defined
    domains = run("domain", "-list", "-all")
    domains.include?('Master') ? true : false
  end
    
end

