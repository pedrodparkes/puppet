# This file is part of the puppet5 module
# 
# This test manifest sets up the Puppetlabs Puppet5 repository and installs the puppet-agent package

include puppet5::repos
class { 'puppet5':
  require => Class['puppet5::repos']
}