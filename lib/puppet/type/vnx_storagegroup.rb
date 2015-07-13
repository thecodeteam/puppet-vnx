# Copyright (C) 2014 EMC, Inc.
Puppet::Type.newtype(:vnx_storagegroup) do
  @doc = "Manage EMC VNX storage groups."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Storage group name."

    validate do |value|
      fail("Invalid Storage group name length") unless value.length <= 64 and value.length > 0
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
