# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'etckeeper' do
  # Each VCS replaces the repository of the previous one
  {
    'git' => 'git',
    'hg' => 'mercurial',
    'bzr' => { 'Archlinux' => 'breezy' },
    'darcs' => 'darcs',
  }.each do |vcs, packages|
    context "with vcs => #{vcs}" do
      paths = EtckeeperAcceptance::VCS[vcs]

      before(:context) do
        package = packages.is_a?(Hash) ? packages.fetch(fact('os.family'), vcs) : packages
        skip "#{package} is not available" unless package_available?(package)
      end

      it_behaves_like 'an idempotent resource' do
        let(:manifest) do
          <<~PUPPET
            class { 'etckeeper':
              vcs                    => '#{vcs}',
              vcs_user_name          => 'Puppet',
              vcs_user_email         => 'puppet@example.com',
              daily_autocommit_timer => true,
            }

            etckeeper::ignore { '#ignored*': }
          PUPPET
        end
      end

      describe file('/etc/etckeeper/etckeeper.conf') do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'root' }
        it { is_expected.to be_mode 644 }
        its(:content) { is_expected.to match(%r{^VCS="#{vcs}"$}) }
      end

      describe service('etckeeper.timer') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe file(paths[:directory]) do
        it { is_expected.to be_directory }
        it { is_expected.to be_mode 700 }
      end

      (EtckeeperAcceptance::VCS.keys - [vcs]).each do |other_vcs|
        describe file(EtckeeperAcceptance::VCS[other_vcs][:directory]) do
          it { is_expected.not_to exist }
        end
      end

      describe file(paths[:ignore_file]) do
        its(:content) { is_expected.to match(%r{^# end section managed by etckeeper$}) }
        its(:content) { is_expected.to match(%r{^#{Regexp.escape(paths[:ignore_line])}$}) }
      end

      describe command('touch /etc/acceptance-test "/etc/#ignored-file" && etckeeper commit "Acceptance test"') do
        its(:exit_status) { is_expected.to eq 0 }
      end

      describe command(paths[:tracked_files]) do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.to match(%r{^(\./)?acceptance-test$}) }
        its(:stdout) { is_expected.to match(%r{^(\./)?etckeeper/etckeeper\.conf$}) }
        its(:stdout) { is_expected.not_to match(%r{ignored-file}) }
      end

      if paths.fetch(:unclean_works, true)
        describe command('etckeeper unclean') do
          its(:exit_status) { is_expected.to eq 1 }
        end
      end

      if paths[:last_commit_identity]
        describe command(paths[:last_commit_identity]) do
          its(:stdout) { is_expected.to eq "#{paths[:identity]}\n" }
        end
      end
    end
  end
end
