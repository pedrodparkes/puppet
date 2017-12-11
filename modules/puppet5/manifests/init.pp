# puppet5 class
# 
# This class is used to install and configure the Puppet 5 agent
# Installing a puppet5 repo is required, however the puppet5::repos class is
# not required as long as a repository is set up prior to calling this class
# 
# This class calls the install, config and service classes in sequence for a simplified
# one class definition of the puppet-agent
# 
# @example Declaring the class
#   include puppet5
#   
# @param [String] package The package to be installed
# @param [String] version The version of the package to be installed
# @param [String] ensure Ensure if the package is `installed` or `absent`, the default is `installed`
# @param [String] service Controls the puppet-agent service, the default is `enabled`

class puppet5(
  String $package,
  String $version,
  Variant[Boolean, Enum['installed', 'absent']] $ensure = 'installed',
  Variant[Boolean, Enum['running', 'stopped']] $service = 'running',
) {

  include puppet5::oscheck

  case $ensure {
    true, 'installed': {
      $ensure_package = $version
      $ensure_dir     = 'directory'
      $ensure_file    = 'file'
      $ensure_present = 'present'
      $ensure_service = $service
    }
    default: {
      $ensure_package  = 'absent'
      $ensure_service  = 'stopped'
      $ensure_dir      = 'absent'
      $ensure_file     = 'absent'
      $ensure_present  = 'absent'
    }
  }

  class {'puppet5::agent::install':
    ensure  => $ensure,
    package => $package,
    version => $version,
  }

  class {'puppet5::agent::config':
    ensure  => $ensure_present,
    require => Class['puppet5::agent::install'],
  }

  class {'puppet5::agent::service':
    ensure => $ensure_service,
  }

}
