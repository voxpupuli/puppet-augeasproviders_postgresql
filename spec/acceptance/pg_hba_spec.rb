# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'pg_hba' do
  before(:all) do
    shell("printf 'local all postgres peer\\nhost all all 127.0.0.1/32 scram-sha-256\\n' > /tmp/pg_hba_test.conf")
  end

  context 'with ensure => present' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          pg_hba { 'local to all on all':
            ensure => present,
            method => 'md5',
            target => '/tmp/pg_hba_test.conf',
          }
          pg_hba { 'host to app on appdb from 192.168.0.0/24':
            ensure  => present,
            method  => 'ldap',
            options => {
              'ldapserver' => 'auth.example.com',
              'ldaptls'    => '1',
            },
            target  => '/tmp/pg_hba_test.conf',
          }
        PUPPET
      end
    end

    describe file('/tmp/pg_hba_test.conf') do
      its(:content) { is_expected.to match(%r{^local\s+all\s+postgres\s+peer$}) }
      its(:content) { is_expected.to match(%r{^local\s+all\s+all\s+md5$}) }
      its(:content) { is_expected.to match(%r{^host\s+appdb\s+app\s+192\.168\.0\.0/24\s+ldap\s+ldapserver="auth\.example\.com"\s+ldaptls="1"$}) }
    end
  end

  context 'with ensure => absent' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          pg_hba { 'host to all on all from 127.0.0.1/32':
            ensure => absent,
            target => '/tmp/pg_hba_test.conf',
          }
        PUPPET
      end
    end

    describe file('/tmp/pg_hba_test.conf') do
      its(:content) { is_expected.not_to match(%r{127\.0\.0\.1}) }
      its(:content) { is_expected.to match(%r{^local\s+all\s+all\s+md5$}) }
    end
  end
end
