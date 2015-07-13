Puppet::Type.newtype(:vnx_ldap) do 
  @doc = "Manage EMC VNX LDAP settings."
  
  ensurable
  
  newparam(:server, :namevar => true) do
    desc "The VNX LD Server IP Address"
    validate do |value|
      fail("#{value} is not a valid IP for LDAP") unless IPAddr.new(value).ipv4?
    end
  end

  newparam(:portnumber) do
    desc "The LDAP Port number, 389 for LDAN, 636 for LDAPS"
    validate do |value|
      fail("Invalid port number for LDAP") unless value==636 or value==389
    end
  end


  newparam(:servertype) do
    desc "The LDAP Server type"
    defaultto :ldap
    newvalues(:ldap, :ad)
  end
  
  newparam(:protocol) do
    desc "The LDAP Protocol"
    defaultto :ldap
    newvalues(:ldap, :ldaps)
  end

  newparam(:binddn) do
    desc "The login for LDAP/AD"
    validate do |value|
      fail("Login cannot exceed 512 characters") if value.length > 512
      fail("Invalid format for LDAP Login") unless value =/^cn=\w+,ou=\w+,dc=\w+,dc=\w+$/
    end
  end

  newparam(:bind_password) do
    desc "The LDAP password"
    validate do |value|
      fail("Password cannot exceed 512 characters") if value.length > 512
    end
  end

  newparam(:user_search_path) do
    desc "The LDAP user search path"
    validate do |value|
      fail("Invalid LDAP user search path") unless value =~/^ou=\w+,dc=\w+,dc=\w+$/
    end
  end
  
  newparam(:group_search_path) do
    desc "The LDAP group search path"
    validate do |value|
      fail("Invalid LDAP group search path") unless value =~/^ou=\w+,dc=\w+,dc=\w+$/
    end
  end
  
  newparam(:user_id_attribute) do
    desc "The attribute to which the user ID will be appended in the LDAP/AD servers"
    validate do |value|
      fail("Invalid user_id_attribute") if value.length > 128
    end
  end

  newparam(:user_name_attribute) do
    desc "The attribute to which the user’s common name (cn) will be appended in the servers"
    validate do |value|
      fail("Invalid user_name_attribute") if value.length > 128
    end
  end

  newparam(:group_name_attribute) do
    desc "The attribute to which the user group’s common name will be appended in the servers"
    validate do |value| 
      fail("Invalid group_name_attribute") if value.length > 128
    end
  end
  
  newparam(:group_member_attribute) do
    desc "A search filter for the different attribute types to identify the different groups of members"
    validate do |value|
      fail("Invalid group_member_attribute") if value.length > 128
    end
  end

  newparam(:user_object_class) do
    desc "A search filter in a situation where a user has multiple entries in a server"
    validate do |value|
      fail("Invalid user_object_class") if value.length > 128
    end
  end

  newparam(:group_object_class) do
    desc "A search filter in a situation where a group has multiple entries in a server"
    validate do |value|
      fail("Invalid group_object_class") if value.length > 128
    end
  end

  newparam(:cert) do
    desc "The pathname of the trusted cert file to be uplodaded to the cert store"
      validate do |value|
        fail("Invalid cert path") unless File.file?(value)
      end
  end 


end
