transport { 'VNX':
  server => '10.13.180.6',
  username => 'nasadmin',
  password => 'nasadmin',
}

vnx_lun { 'test_lun':
  ensure => present,
  capacity => 10,
  pool_name => 'just_test',
  transport => Transport['VNX'],
}