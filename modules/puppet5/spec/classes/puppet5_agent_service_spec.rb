require 'spec_helper'

describe 'puppet5::agent::service' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { should contain_class('puppet5::oscheck') }

      context "with no paramters" do
        case facts[:operatingsystemmajrelease]
        when '7'
          it { should contain_file('puppet_systemd_unit').with(
            'ensure'  => 'file',
            'path'    => @service_files[:systemd_service_unit],
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'before'  => 'Service[puppet-agent]',
          )}
        else
          it { should_not contain_file('puppet_systemd_unit') }
        end
        it { should contain_service('puppet-agent').with(
          'ensure' => 'running',
          'enable' => true,
        )}
      end

      context "when ensure is stopped" do
        let :params do
          {
            :ensure => 'stopped'
          }
        end
        it { should contain_service('puppet-agent').with(
          'ensure' => 'stopped',
          'enable' => false,
        )}
      end

      context "when ensure is an incorrect value" do
        let :params do
          {
            :ensure => 'anything'
          }
        end
        it { should raise_error(
          Puppet::Error,
          /\[Puppet5::Agent::Service\]: parameter 'ensure' expects a value of type Boolean or Enum\['running', 'stopped'\]/
        ) }
      end

    end
  end
end
