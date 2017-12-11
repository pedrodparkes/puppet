#!/bin/bash
apt-get update -y
apt-get upgrade -y

# Install puppet client
# wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
# sudo dpkg -i puppetlabs-release-pc1-xenial.deb
# sudo apt-get update -y
# apt-get install puppet-agent
# Install puppet client - New Way
wget -O - https://raw.githubusercontent.com/petems/puppet-install-shell/master/install_puppet_5_agent.sh | sudo sh

# fix puppet path
echo "PATH=\"$PATH:/opt/puppetlabs/puppet/bin\"" > /etc/environment
source /etc/environment
# PATH=$PATH:/opt/puppetlabs/puppet/bin/
# export PATH
# echo "PATH=$PATH:/opt/puppetlabs/puppet/bin/" >> $HOME/.bashrc
# echo "export PATH" >> $HOME/.bashrc

# Set puppet conf
cat >/etc/puppetlabs/puppet/puppet.conf  <<EOL
# Managed by AWS Userdata
[agent]
server = puppet.mc
certname = bastion.mc
environment = dev
runinterval = 30m
EOL

echo "Bastion" > /etc/hostname
localIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "$localIP bastion.mc bastion" >> /etc/hosts
hostname bastion.mc

/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

# Run puppet in solo mode to finalize config
cat >/etc/puppetlabs/code/environments/production/manifests/bastion.pp <<EOL
# Managed by AWS Userdata
node "bastion.mc" {

file { '/root/example_file.txt':
    ensure => "file",
    owner  => "root",
    group  => "root",
    mode   => "700",
    content => "Congratulations!
				Puppet has created this file.",
	}
}
EOL
