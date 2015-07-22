#Puppet VNX Module
Puppet VNX module wraps Naviseccli into Puppet module to simplify the configuration of VNX Initiator, DNS, Storage Pool, Hot Spare, Storage Group, LUN, Fast Cache, NTP, Domain, SP and Array.

Prepare
-------
Download and install Navisphere CLI

For VNX1 Series: https://support.emc.com/downloads/12781_VNX1-Series

For VNX2 Series: https://support.emc.com/downloads/36656_VNX2-Series

Example
-------
```puppet
transport {'vnx5400':
  username => 'nasadmin',
  password => 'nasadmin',
  server   => '10.10.166.9'
}

vnx_storagepool {"elc-cloud":
  disks => ['0_0_4', '0_0_5', '0_0_6', '0_0_7', '0_0_8'],
  raid_type => 'r_5',
  transport => Transport['vnx5400'],
  ensure => present
}
```
Notice: Type parameters refer to Navisphere CLI parameters


TO DO
-------
* Add more configurable resources


License
-------
Licensed under the Apache License, Version 2.0 (the “License”). See LICENSE for details. 


Contact
-------
jie.bao@emc.com
layne.peng@emc.com
grissom.wang@emc.com


Support
-------
Please file bugs and issues at the <a href="https://github.com/emccode/puppet-vnx/issues">Github issues</a> page.  For more general discussions you can contact the EMC Code team at <a href="https://groups.google.com/forum/#!forum/emccode-users">Google Groups</a>.  The code and documentation are released with no warranties or SLAs and are intended to be supported through a community driven process.


Please log tickets and issues at our [Projects site](http://projects.example.com)
