Puppet::Type.newtype(:vnx_domain) do 
  @doc = "Manage EMC VNX Domain settings."
  
  ensurable
  
  newparam(:domain, :namevar => true) do 
    desc "The VNX Domain name"
  end
 
  newproperty(:ensure_member) do
    desc "Ensure a system is part of a VNX domain."
    newvalues(:true, :false)
  end

  newparam(:ensure_master) do
    desc "Sets the specified system as the domain master"
    newvalues(:true)
  end

  newparam(:domain_member) do
    desc "The IP address of the system to add to the VNX domain"
    validate do |value|
      fail("Invalid IP address specified for Domain member") unless IPAddr.new(value).ipv4?
    end
  end
  
  newparam(:old_user) do
    desc "Specify user to add system"
  end
  
  newparam(:old_password) do
    desc "Password for user"
  end
  
  newparam(:old_scope) do
    desc "The user scope, global, local, or LDAP"
    newvalues(:global, :local, :LDAP)
  end

  validate do 
    if self[:old_scope] or self[:old_password] or self[:old_user]
      fail("Must specify user, password and scope together") unless self[:old_scope] and self[:old_password] and self[:old_user]
    end
  end

end
