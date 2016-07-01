Puppet::Type.newtype(:vnx_eventtemplate) do 
  @doc = "Manage VNX Event Monitor Templates."
  
  newparam(:template_name, :namevar => true) do
    desc "The Template Name"
    validate do |value| 
      fail("Invalid template name format") unless value =~/^\w+$/
    end
  end

  newparam(:template_filename) do
    desc "The Template filename to be imported to the template database"
    validate do |value|
      fail("Template filename is not a valid file path") unless File.file?(value)
    end
  end

  newparam(:file_path) do 
    desc "The File path for exported templates"
    validate do |value|
      fail("Invalid file path specifed for export") unless File.directory?(value)
    end
  end

  newparam(:ensure_imported) do
    desc "Imports the template file"
    defaultto :true
  end

  newparam(:ensure_exported) do
    desc "Exports the template file"
    defaultto :true
  end
  
  newparam(:resolve_conflict) do
    desc "Resolves Template conflicts"
    defaultto :true
  end

  newparam(:ensure_swapped) do
    desc "Swaps the specified template with the current template name" 
    validate do |value|
      fail("Invalid template name format") unless value =~/^\w+$/ 
    end
  end

end
