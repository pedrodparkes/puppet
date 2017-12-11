# puppet5::repos class
# 
# This class is used to install the Puppet 5 package repositories
# 
# @example Declaring the class
#   include puppet5::repos
#   
# @param [Boolean] sources If true the Puppet5 source repository will also be installed

class puppet5::repos (
  Boolean $sources = false
) {

  include puppet5::oscheck

  file { 'puppet5_repo_gpgkey':
    ensure => file,
    path   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5',
    source => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppet'
  }

  yumrepo { 'puppet5':
    enabled  => true,
    descr    => "The Puppetlabs Puppet5 Package el ${::operatingsystemmajrelease} repository",
    baseurl  => "http://yum.puppetlabs.com/puppet5/el/${::operatingsystemmajrelease}/\$basearch",
    gpgcheck => true,
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5',
    require  => File['puppet5_repo_gpgkey']
  }

  if $sources {
    yumrepo { 'puppet5-SRPMS':
      enabled  => true,
      descr    => "The Puppetlabs Puppet5 Package el ${::operatingsystemmajrelease} repository - Sources",
      baseurl  => "http://yum.puppetlabs.com/puppet5-nightly/el/${::operatingsystemmajrelease}/SRPMS",
      gpgcheck => true,
      gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5',
      require  => File['puppet5_repo_gpgkey']
    }
  }

}