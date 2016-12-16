# Copyright (C) 2014 EMC, Inc.
Puppet::Type.newtype(:vnx_storagegroup) do
  @doc = "Manage EMC VNX storage groups."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Storage group name."

#    validate do |value|
#      fail("Invalid Storage group name length") unless value.length <= 128 and value.length > 0
#    end
  end

  newparam(:sg_name) do
    desc "Storage group name."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:hbauid) do
    desc "The HBA UID for an Initiator"

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:sp) do
    desc "Owner SP."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:sp_port) do
    desc "Owner SP."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:initiator_type) do
    desc "Owner SP."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:ip_address) do
    desc "The IP address of virtual machine"
    validate do |value|
      fail("#{value} is not a valid IPv4 address") unless value.nil? || IPAddr.new(value).ipv4?
    end
  end

  newproperty(:hostname) do
    desc "Owner SP."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:failover_mode) do
    desc "Owner SP."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:array_commpath) do
    desc "Owner SP."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:unit_serialnumber) do
    desc "Owner SP."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:setpathonly) do
    desc "addonly only used when you don't want to move anything from storagegroup"
    newvalues(:true, :false)
  end


  newproperty(:addonly) do
    desc "addonly only used when you don't want to move anything from storagegroup"
    newvalues(:true, :false)
  end

  newproperty(:host_name) do
    desc "Host name."

    validate do |value|
      fail("Invalid Host name length") unless value.length <= 64 and value.length > 0
    end
  end

  newproperty(:uid) do
    desc "Storage group uid."

    validate do
      fail "uid is read-only"
    end
  end

  newproperty(:shareable) do
    desc "The storage group shareable property."
    newvalues(:true, :false)
    validate do
      fail "shareable is read-only"
    end
  end

  newproperty(:new_name) do
    desc "The storage group new name."
  end

  newproperty(:HBAs, :array_matching => :all) do
    desc "HBA/SP Pairs"
    validate do
      fail "hba_sp_pairs is read-only"
    end
  end

  newproperty(:luns, :array_matching => :all) do
    desc "HLU/ALU Pairs"

    def insync? is
      if [is, should].all?{|v| v.respond_to?(:map)}
        is.map{|pair| pair.values_at('hlu', 'alu').map &:to_s}.sort == should.map{|pair| pair.values_at('hlu', 'alu').map &:to_s}.sort
      else
        (is || :absent) == (should || :absent)
      end
    end
  end
end
