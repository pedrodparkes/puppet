require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
require 'coveralls'
include RspecPuppetFacts

Coveralls.wear!

RSpec.configure do |c|
  c.hiera_config = "hiera.yaml"

  c.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables]=true
    end

    # Declare variable lookup tables for testing here, so they can be reused across tests
    @package_details = {
      'redhat-6-x86_64' => {
        :version => '5.0.0-1.el6',
        :package => 'puppet-agent',
      },
      'redhat-7-x86_64' => {
        :version => '5.0.0-1.el7',
        :package => 'puppet-agent',
      },
      'centos-6-x86_64' => {
        :version => '5.0.0-1.el6',
        :package => 'puppet-agent',
      },
      'centos-7-x86_64' => {
        :version => '5.0.0-1.el7',
        :package => 'puppet-agent',
      },
    }

    @install_directories = {
      :base          => '/etc/puppetlabs',
      :code          => '/etc/puppetlabs/code',
      :mcollective   => '/etc/puppetlabs/mcollective',
      :puppet        => '/etc/puppetlabs/puppet',
      :modules       => '/etc/puppetlabs/code/modules',
      :environments  => '/etc/puppetlabs/code/environments',
      :ssl           => '/etc/puppetlabs/puppet/ssl',
      :cert_requests => '/etc/puppetlabs/puppet/ssl/certificate_requests',
      :certs         => '/etc/puppetlabs/puppet/ssl/certs',
      :private_certs => '/etc/puppetlabs/puppet/ssl/private',
      :private_keys  => '/etc/puppetlabs/puppet/ssl/private_keys',
      :public_keys   => '/etc/puppetlabs/puppet/ssl/public_keys',
      :pxp_agent     => '/etc/puppetlabs/pxp-agent',
      :pxp_modules   => '/etc/puppetlabs/pxp-agent/modules'
    }

    @config_files = {
      :puppetconf => '/etc/puppetlabs/puppet/puppet.conf'
    }

    @service_files = {
      :systemd_service_unit => '/usr/lib/systemd/system/puppet.service'
    }
  end
end

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end
