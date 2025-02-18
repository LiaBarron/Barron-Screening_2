class monitor_setup {

  # Install required packages
  package { ['vim', 'curl', 'git']:
    ensure => installed,
  }

  # Create user 'monitor' with specified home and shell
  user { 'monitor':
    ensure     => present,
    home       => '/home/monitor',
    shell      => '/bin/bash',
    managehome => true,
  }

  # Ensure /home/monitor/scripts directory exists
  file { '/home/monitor/scripts/':
    ensure  => directory,
    owner   => 'monitor',
    group   => 'monitor',
    mode    => '0755',
  }

  # Download memory check script from GitHub
  exec { 'download_memory_check':
    command => 'wget -O /home/monitor/scripts/memory_check https://raw.githubusercontent.com/YOUR_GITHUB_REPO/memory_check.sh',
    creates => '/home/monitor/scripts/memory_check',
    require => File['/home/monitor/scripts/'],
  }

  # Ensure script has execute permissions
  file { '/home/monitor/scripts/memory_check':
    ensure  => file,
    owner   => 'monitor',
    group   => 'monitor',
    mode    => '0755',
    require => Exec['download_memory_check'],
  }

  # Ensure /home/monitor/src directory exists
  file { '/home/monitor/src/':
    ensure  => directory,
    owner   => 'monitor',
    group   => 'monitor',
    mode    => '0755',
  }

  # Create symbolic link in /home/monitor/src
  file { '/home/monitor/src/my_memory_check':
    ensure  => link,
    target  => '/home/monitor/scripts/memory_check',
    owner   => 'monitor',
    group   => 'monitor',
    require => [ File['/home/monitor/src/'], File['/home/monitor/scripts/memory_check'] ],
  }

  # Add cron job to run script every 10 minutes
  cron { 'run_memory_check':
    user    => 'monitor',
    command => '/home/monitor/src/my_memory_check',
    minute  => '*/10',
    require => File['/home/monitor/src/my_memory_check'],
  }

}
