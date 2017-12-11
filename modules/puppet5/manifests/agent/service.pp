# puppet5::agent::service class
# 
# This class is used to configure the Puppet 5 agent
# 
# @example Declaring the class
#   include puppet5::service
#
# NOTE: Spaces are stripped from paths when they substituted into puppet.conf
#       What kind of monster uses spaces in paths?
#       
# @param [String] ensure If set to 'enabled' the puppet-agent service runs at boot.

class puppet5::agent::service(
  Variant[Boolean, Enum['running', 'stopped']] $ensure = 'running',
) {

  include puppet5::oscheck

  case $ensure {
    true, 'running': {
      $service_enable = true
      $ensure_file = 'file'
    }
    default: {
      $service_enable = false
      $ensure_file = 'absent'
    }
  }

  case $::operatingsystemmajrelease {
    '7': {
      # Use systemd
      file{'puppet_systemd_unit':
        ensure  => $ensure_file,
        path    => lookup('puppet5::service::systemd_unit'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('puppet5/puppet.service.erb'),
        before  => Service['puppet-agent'],
      }
    }
    default: {
      # Use init.d/rc.d
      # Do nothing for now
    }
  }

  service{'puppet-agent':
    ensure => $ensure,
    enable => $service_enable,
  }

}