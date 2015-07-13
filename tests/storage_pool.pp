transport { 'VNX':
  server => '10.13.180.6',
  username => 'nasadmin',
  password => 'nasadmin',
}

vnx_storagepool { 'test_pool':
  ensure => present,
  raid_type => r_5,
  disks => ['0_1_0', '0_1_1', '0_1_2', '0_1_3', '0_1_4'],
  transport => Transport['VNX'],
}