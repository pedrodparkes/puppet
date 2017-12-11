node puppet.mc {
  # Configure puppetdb and its underlying database
  class { 'puppetdb': }
  # Configure the Puppet master to use puppetdb
  class { 'puppetdb::master::config': }
  # Configure puppet Master to checkout the repo and autosign new nodes
  class { 'mcpuppet': 
    repo_dir => "/etc/puppetlabs/code/environments/moovcheckout",
    ensure   => latest,
    source   => 'git@github.com:moovweb/mc-puppet.git',
    revision => 'master',
    autosign => true,
  }
}

node bastion.mc {
}