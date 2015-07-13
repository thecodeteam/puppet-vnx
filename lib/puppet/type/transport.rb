Puppet::Type.newtype(:transport) do
  @doc = "Manage transport connectivity info such as username, password, server, scope."

  newparam(:name, :namevar => true) do
    desc "The name of the network transport."
  end

  newparam(:username) do
  end

  newparam(:password) do
  end

  newparam(:server) do
  end

  newparam(:scope) do
    defaultto 0
    newvalues(0,1,2)
  end

  newparam(:cli_path) do
    defaultto "/opt/Navisphere/bin/naviseccli"
  end
end

unless Puppet::Type.metaparams.include? :transport
  Puppet::Type.newmetaparam(:transport) do
    desc "Provide a new metaparameter for all resources called transport."
  end
end
