require 'spec_helper'

describe 'gluster::repo::apt' do
  on_supported_os.each do |os, facts|
    next unless facts[:osfamily] == 'Debian'
    context "on #{os}" do
      let(:facts) { facts }

      context 'with all defaults' do
        it { is_expected.to contain_class('gluster::params') }
        it { is_expected.to contain_class('gluster::repo::apt') }
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_apt__source('glusterfs-6-LATEST')
            .with_key('id' => 'F9C958A3AEE0D2184FAD1CBD43607F0DC2F8238C', 'key_source' => 'https://download.gluster.org/pub/gluster/glusterfs/6/rsa.pub')
            .with_location("https://download.gluster.org/pub/gluster/glusterfs/6/LATEST/Debian/#{facts[:lsbdistcodename]}/#{facts[:architecture]}/apt/")
        end
      end

      context 'unsupported architecture' do
        let(:facts) { super().merge(architecture: 'zLinux') }
        it { is_expected.to compile.and_raise_error(%r{not yet supported}) }
      end

      context 'latest Gluster with priority' do
        let :params do
          {
            priority: '700'
          }
        end

        it { is_expected.to contain_apt__source('glusterfs-6-LATEST').with_pin('700') }
      end

      context 'Specific Gluster release 4.1' do
        let :params do
          {
            release: '4.1'
          }
        end

        it do
          is_expected.to contain_apt__source('glusterfs-4.1-LATEST')
            .with_key('id' => 'EED3351AFD72E5437C050F0388F6CDEE78FA6D97', 'key_source' => 'https://download.gluster.org/pub/gluster/glusterfs/4.1/rsa.pub')
            .with_location("https://download.gluster.org/pub/gluster/glusterfs/4.1/LATEST/Debian/#{facts[:lsbdistcodename]}/amd64/apt/")
        end
      end

      context 'Specific Gluster release 6.3' do
        let :params do
          {
            release: '6',
            version: '6.3'
          }
        end

        it do
          is_expected.to contain_apt__source('glusterfs-6-6.3')
            .with_key('id' => 'F9C958A3AEE0D2184FAD1CBD43607F0DC2F8238C', 'key_source' => 'https://download.gluster.org/pub/gluster/glusterfs/6/rsa.pub')
            .with_location("https://download.gluster.org/pub/gluster/glusterfs/6/6.3/Debian/#{facts[:lsbdistcodename]}/amd64/apt/")
        end
      end
    end
  end
end
