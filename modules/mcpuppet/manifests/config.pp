#== mcpuppet::config
#
class mcpuppet::config inherits mcpuppet {

file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("$module_name/hiera.yaml.erb"),
  }
  file { '/etc/puppetlabs/puppet/autosign.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("$module_name/autosign.yaml.erb"),
  }
  file { $repo_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  if $::virtual != 'virtualbox' {
    crit("PUPPET ON AWS")
    file { '/etc/puppetlabs/puppet/puppet.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("$module_name/puppet.yaml.erb"),
    }
    vcsrepo { $repo_dir:
      ensure   => $ensure,
      provider => git,
      source   => $source,
      revision => $revision,
      require  => File[$repo_dir],
    }
  }
  else {
    crit("VAGRANT+VIRTUALBOX")
    alert("Applying Vagrant config: environment = dev, vcsrepo = false")
    file { '/etc/puppetlabs/puppet/puppet.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("$module_name/puppet-vagrant.yaml.erb"),
    }
  }
}