require 'spec_helper'

describe 'puppet5::repos' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { should contain_class('puppet5::oscheck') }

      it { should contain_file('puppet5_repo_gpgkey').with(
        'ensure' => 'file',
        'path'   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5',
        'source' => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppet'
      ) }

      it { should contain_yumrepo('puppet5').with(
        'enabled'  => true,
        'descr'    => "The Puppetlabs Puppet5 Package el #{facts[:operatingsystemmajrelease]} repository",
        'baseurl'  => "http://yum.puppetlabs.com/puppet5/el/#{facts[:operatingsystemmajrelease]}/\$basearch",
        'gpgcheck' => true,
        'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5',
        'require'  => ['File[puppet5_repo_gpgkey]']
      ) }

      context 'with no parameters' do
        it { should_not contain_yumrepo('puppet5-SRPMS') }
      end

      context 'when sources => true' do
        let :params do
          {
            :sources => true
          }
        end
        it { should contain_yumrepo('puppet5-SRPMS').with(
          'enabled'  => true,
          'descr'    => "The Puppetlabs Puppet5 Package el #{facts[:operatingsystemmajrelease]} repository - Sources",
          'baseurl'  => "http://yum.puppetlabs.com/puppet5-nightly/el/#{facts[:operatingsystemmajrelease]}/SRPMS",
          'gpgcheck' => true,
          'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet5',
          'require'  => ['File[puppet5_repo_gpgkey]']
        ) }
      end

    end
  end
end