transport { 'VNX':
  server => '10.13.180.6',
  username => 'nasadmin',
  password => 'nasadmin',
}

vnx_initiator { 'iqn_test':
  ensure => present,
  hostname => 'test_host',
  ip_address => '10.32.105.149',
  ports => [ {'sp' => a, 'sp_port' => 1} ],
  transport => Transport['VNX'],
}