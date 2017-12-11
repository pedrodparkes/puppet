require 'spec_helper'

describe 'puppet5::oscheck' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

    end
  end
  context 'on a RedHat 4 OS' do
    let :facts do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => '4',
        :concat_basedir            => '/dne',
      }
    end
    it { should raise_error(Puppet::Error, /The puppet5 module does not support release 4 of RedHat family of operating systems/) }
  end
  context 'on a RedHat 5 OS' do
    let :facts do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => '5',
        :concat_basedir            => '/dne',
      }
    end
    it { should raise_error(Puppet::Error, /The puppet5 module does not support release 5 of RedHat family of operating systems/) }
  end
  context 'on an Unknown OS' do
    let :facts do
      {
        :osfamily       => 'Unknown',
        :concat_basedir => '/dne',
      }
    end
    it { should raise_error(Puppet::Error, /The puppet5 module does not support Unknown family of operating systems/) }
  end
end