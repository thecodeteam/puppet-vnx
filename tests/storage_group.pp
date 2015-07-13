transport { 'VNX':
  server => '10.13.180.6',
  username => 'nasadmin',
  password => 'nasadmin',
}

vnx_storagegroup { 'test_group':
  ensure => present,
  hlu_alu_pairs => [ {'hlu_number' => 0, 'alu_number' => 11} ],
}