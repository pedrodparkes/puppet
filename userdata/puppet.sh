#!/bin/bash
# Puppet agent install based on https://github.com/petems/puppet-install-shell
# Puppet_db and Puppet configuration based on puppetlabs-puppetdb module
ENVIRONMENT='moovcheckout'
HOSTNAME='puppet'
DOMAIN='mc'
BUCKET='puppetprivate-920877798033'
# Make cloud-init stream logs to grub them from local PC with
# 
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Upgrade Ubuntu"
apt-get update -y
apt-get upgrade -y
apt-get install links awscli -y
echo "Download public and private keys"
aws s3 cp s3://$BUCKET/id_rsa.pub.enc /tmp/
aws s3 cp s3://$BUCKET/id_rsa.enc /tmp/
echo "Done: Download public and private keys = $?"
cat << EOF > /root/secret.key
PUT-YOUR-SECRET-HERE
EOF
openssl aes-256-cbc -d -in /tmp/id_rsa.enc -out /root/.ssh/id_rsa -pass file:/root/secret.key         #decrypt
openssl aes-256-cbc -d -in /tmp/id_rsa.pub.enc -out /root/.ssh/id_rsa.pub -pass file:/root/secret.key #decrypt
chmod 600 /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa.pub
# Install puppet client
echo "Install puppet client"
wget -O - https://raw.githubusercontent.com/petems/puppet-install-shell/master/install_puppet_5_agent.sh | sudo sh
echo "Done: Install puppet client = $?"
echo "Fix puppet path"
PATH=$PATH:/opt/puppetlabs/puppet/bin
export PATH
echo "PATH=$PATH:/opt/puppetlabs/puppet/bin" >> /etc/profile
echo "export PATH" >> /etc/profile
source /etc/profile
echo "Done: Fix puppet path =  $?"

echo "Set puppet conf"
cat << EOF > /etc/puppetlabs/puppet/puppet.conf
# Managed by AWS Userdata
[agent]
server = puppet.mc
certname = $HOSTNAME.$DOMAIN
environment = $ENVIRONMENT
runinterval = 30m
EOF
echo "Set hostname"
echo "$HOSTNAME" > /etc/hostname
localIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "$localIP $HOSTNAME.$DOMAIN $HOSTNAME" >> /etc/hosts
hostname $HOSTNAME.$DOMAIN
echo "Enable puppet agent"
/opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
echo "Done: Enable puppet agent = $?"
echo "Install puppet server"
apt-get install puppetserver -y
echo "Done: Install puppet server = $?"
echo "Enable puppet server"
systemctl start puppetserver
echo "Done: Enable puppet server = $?"
echo "Request certificate"
puppet agent -t --verbose --server puppet.mc
echo "Done: Request certificate = $?"
echo "Install required puppetlabs modules"
/opt/puppetlabs/bin/puppet module install puppetlabs-puppetdb --version 6.0.2
puppet module install puppetlabs-vcsrepo --version 2.2.0
echo "Done: Install required puppetlabs modules = $?"
echo "Add GitHub to known_hosts to make Git uninteractive"
ssh-keyscan github.com >> ~/.ssh/known_hosts
echo "Done: Add GitHub to known_hosts to make Git uninteractive = $?"
cat << EOF > /etc/puppetlabs/puppet/puppet.conf
# Managed by AWS Userdata
[agent]
server = puppet.mc
certname = $HOSTNAME.$DOMAIN
environment = $ENVIRONMENT
runinterval = 30m
EOF
cat << EOF > /tmp/$HOSTNAME.pp
# Managed by AWS Userdata
node $HOSTNAME.$DOMAIN{
	# Configure puppetdb and its underlying database
	class { 'puppetdb': }
	# Configure the Puppet master to use puppetdb
	class { 'puppetdb::master::config': }
	# Download Puppet infrastructure
	\$repo_dir = "/etc/puppetlabs/code/environments/$ENVIRONMENT"
	\$ensure = latest
	\$source = 'git@github.com:moovweb/moovcheckout-puppet.git'
	\$revision = 'master'
	file { \$repo_dir:
		ensure => directory,
		owner  => 'root',
		group  => 'root',
		mode   => '0755',
	}
	vcsrepo { \$repo_dir:
	ensure   => \$ensure,
	provider => git,
	source   => \$source,
	revision => \$revision,
	require  => File[\$repo_dir],
	}
}
EOF
echo "Install puppet_db"
/opt/puppetlabs/bin/puppet apply /tmp/$HOSTNAME.pp
echo "Done: Install puppet_db = $?"