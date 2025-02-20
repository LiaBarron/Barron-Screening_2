class monitor_setup {

  package { ['vim', 'curl', 'git']:
    ensure => installed,
  }


  user { 'monitor':
    ensure     => present,
    home       => '/home/monitor',
    shell      => '/bin/bash',
    managehome => true,
  }

  
  file { '/home/monitor/scripts/':
    ensure  => directory,
    owner   => 'monitor',
    group   => 'monitor',
    mode    => '0755',
  }

  
  exec { 'download_memory_check':
    command => 'wget -O /home/monitor/scripts/memory_check https://github.com/LiaBarron/Barron-Screening_2/memory_check.sh',
    creates => '/home/monitor/scripts/memory_check',
    require => File['/home/monitor/scripts/'],
  }


  file { '/home/monitor/scripts/memory_check':
    ensure  => file,
    owner   => 'monitor',
    group   => 'monitor',
    mode    => '0755',
    require => Exec['download_memory_check'],
  }

  
  file { '/home/monitor/src/':
    ensure  => directory,
    owner   => 'monitor',
    group   => 'monitor',
    mode    => '0755',
  }

  
  file { '/home/monitor/src/my_memory_check':
    ensure  => link,
    target  => '/home/monitor/scripts/memory_check',
    owner   => 'monitor',
    group   => 'monitor',
    require => [ File['/home/monitor/src/'], File['/home/monitor/scripts/memory_check'] ],
  }

 
  cron { 'run_memory_check':
    user    => 'monitor',
    command => '/home/monitor/src/my_memory_check',
    minute  => '*/10',
    require => File['/home/monitor/src/my_memory_check'],
  }


  file { '/etc/timezone':
    ensure  => file,
    content => "Asia/Manila\n",
    require => Package['tzdata'],
  }
  exec { 'update_timezone':
    command => 'dpkg-reconfigure -f noninteractive tzdata',
    refreshonly => true,
    subscribe => File['/etc/timezone'],
  }


  file { '/etc/hostname':
    ensure  => file,
    content => "bpx.server.local\n",
  }
  exec { 'update_hostname':
    command => 'hostname bpx.server.local',
    refreshonly => true,
    subscribe => File['/etc/hostname'],
  }

}
