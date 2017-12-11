# This file is part of the puppet5 module
# 
# This test manifest sets up the Puppetlabs Puppet5 repository step by step without using the
# puppet5 wrapper class

include puppet5::repos
class { 'puppet5::agent::install':
  require => Class['puppet5::repos']
}
class { 'puppet5::agent::config':
  require => Class['puppet5::agent::repos']
}
class { 'puppet5::agent::service':
  require => Class['puppet5::agent::config']
}