Puppet::Type.type(:transport).provide(:default) do

  #defaultfor :default_provider => 'true'

  desc 'Basic provider for transport that just returns the value passed into the resource'
 
  def name
    resource[:name]
  end

  def username
    resource[:username]
  end

  def password
    resource[:password]
  end

  def server
    resource[:server]
  end

  def scope
    resource[:scope]
  end

  def cli_path
    resource[:cli_path]
  end

end
