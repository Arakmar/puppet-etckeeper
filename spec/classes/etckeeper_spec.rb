# frozen_string_literal: true

require 'spec_helper'

describe 'etckeeper' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      package_managers = {
        'Archlinux' => ['pacman', 'pacman'],
        'Debian' => ['apt', 'dpkg'],
        'RedHat' => ['dnf', 'rpm'],
      }.fetch(os_facts[:os]['family'])

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('etckeeper::install').that_comes_before('Class[etckeeper::config]') }
        it { is_expected.to contain_class('etckeeper::config').that_comes_before('Class[etckeeper::repository]') }
        it { is_expected.to contain_class('etckeeper::repository') }

        it { is_expected.to contain_package('etckeeper').with_ensure('installed') }
        it { is_expected.to contain_package('git').with_ensure('installed').that_comes_before('Exec[etckeeper init]') }

        it { is_expected.to contain_file('/etc/etckeeper').with_ensure('directory').with_owner('root').with_group('root').with_mode('0755') }

        it 'writes etckeeper.conf' do
          is_expected.to contain_file('/etc/etckeeper/etckeeper.conf')
            .with_ensure('file')
            .with_owner('root')
            .with_group('root')
            .with_mode('0644')
            .with_content(<<~CONF)
              # This file is managed by Puppet.

              # The VCS to use.
              VCS="git"

              # Options passed to git commit when run by etckeeper.
              GIT_COMMIT_OPTIONS=""

              # Options passed to hg commit when run by etckeeper.
              HG_COMMIT_OPTIONS=""

              # Options passed to bzr commit when run by etckeeper.
              BZR_COMMIT_OPTIONS=""

              # Options passed to darcs record when run by etckeeper.
              DARCS_COMMIT_OPTIONS="-a"

              # The high-level package manager that's being used.
              HIGHLEVEL_PACKAGE_MANAGER=#{package_managers[0]}

              # The low-level package manager that's being used.
              LOWLEVEL_PACKAGE_MANAGER=#{package_managers[1]}

              # Remotes each commit is pushed to.
              PUSH_REMOTE=""
            CONF
        end

        it do
          is_expected.to contain_exec('etckeeper init')
            .with_command('etckeeper init')
            .with_creates('/etc/.git')
            .with_cwd('/etc')
        end

        ['/etc/.bzr', '/etc/.hg', '/etc/_darcs'].each do |directory|
          it { is_expected.to contain_file(directory).with_ensure('absent').with_force(true).that_comes_before('Exec[etckeeper init]') }
        end

        ['/etc/.bzrignore', '/etc/.hgignore', '/etc/.darcsignore'].each do |ignore_file|
          it { is_expected.to contain_file(ignore_file).with_ensure('absent').that_comes_before('Exec[etckeeper init]') }
        end

        it { is_expected.to contain_file('/etc/.gitignore').with_ensure('file').that_comes_before('Exec[etckeeper init]') }
        it { is_expected.not_to contain_file('/etc/.git') }
      end

      {
        'bzr' => { directory: '/etc/.bzr', ignore_file: '/etc/.bzrignore', package: (os_facts[:os]['family'] == 'Archlinux') ? 'breezy' : 'bzr' },
        'darcs' => { directory: '/etc/_darcs', ignore_file: '/etc/.darcsignore', package: 'darcs' },
        'hg' => { directory: '/etc/.hg', ignore_file: '/etc/.hgignore', package: 'mercurial' },
      }.each do |vcs, paths|
        context "with vcs => #{vcs}" do
          let(:params) { { vcs: vcs } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package(paths[:package]).that_comes_before('Exec[etckeeper init]') }
          it { is_expected.not_to contain_package('git') }
          it { is_expected.to contain_file('/etc/etckeeper/etckeeper.conf').with_content(%r{^VCS="#{vcs}"$}) }
          it { is_expected.to contain_exec('etckeeper init').with_creates(paths[:directory]) }
          it { is_expected.to contain_file('/etc/.git').with_ensure('absent').with_force(true) }
          it { is_expected.to contain_file('/etc/.gitignore').with_ensure('absent') }
          it { is_expected.to contain_file(paths[:ignore_file]).with_ensure('file').that_comes_before('Exec[etckeeper init]') }
          it { is_expected.not_to contain_file(paths[:directory]) }
        end
      end

      context 'without managing the VCS package' do
        let(:params) { { manage_vcs_package: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('etckeeper') }
        it { is_expected.not_to contain_package('git') }
      end

      context 'with the VCS package installed by another class' do
        let(:pre_condition) { "stdlib::ensure_packages(['git'])" }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('git').with_ensure('installed').that_comes_before('Exec[etckeeper init]') }
      end

      context 'with a VCS that has no package' do
        let(:params) { { vcs: 'darcs', vcs_packages: { 'git' => 'git' } } }

        it { is_expected.to compile.and_raise_error(%r{no package is known for the VCS darcs}) }
      end

      context 'with other package names' do
        let(:params) { { package_name: 'etckeeper-git', vcs_packages: { 'git' => 'git-core' } } }

        it { is_expected.to contain_package('etckeeper-git') }
        it { is_expected.to contain_package('git-core').that_comes_before('Exec[etckeeper init]') }
      end

      context 'with every option' do
        let(:params) do
          {
            conf_dir: '/usr/local/etc/etckeeper',
            highlevel_package_manager: 'apk',
            lowlevel_package_manager: 'apk',
            git_commit_options: '--quiet',
            hg_commit_options: '--quiet',
            bzr_commit_options: '--quiet',
            darcs_commit_options: '-a --quiet',
            avoid_daily_autocommits: true,
            avoid_special_file_warning: true,
            avoid_commit_before_install: true,
            push_remotes: ['origin', 'backup'],
          }
        end

        it { is_expected.to contain_file('/usr/local/etc/etckeeper').with_ensure('directory') }

        it 'writes etckeeper.conf' do
          is_expected.to contain_file('/usr/local/etc/etckeeper/etckeeper.conf').with_content(<<~CONF)
            # This file is managed by Puppet.

            # The VCS to use.
            VCS="git"

            # Options passed to git commit when run by etckeeper.
            GIT_COMMIT_OPTIONS="--quiet"

            # Options passed to hg commit when run by etckeeper.
            HG_COMMIT_OPTIONS="--quiet"

            # Options passed to bzr commit when run by etckeeper.
            BZR_COMMIT_OPTIONS="--quiet"

            # Options passed to darcs record when run by etckeeper.
            DARCS_COMMIT_OPTIONS="-a --quiet"

            # Do not commit the changes of /etc from the daily cron job.
            AVOID_DAILY_AUTOCOMMITS=1

            # Do not warn about special files.
            AVOID_SPECIAL_FILE_WARNING=1

            # Cancel the installation of packages when /etc has uncommitted changes,
            # instead of committing them.
            AVOID_COMMIT_BEFORE_INSTALL=1

            # The high-level package manager that's being used.
            HIGHLEVEL_PACKAGE_MANAGER=apk

            # The low-level package manager that's being used.
            LOWLEVEL_PACKAGE_MANAGER=apk

            # Remotes each commit is pushed to.
            PUSH_REMOTE="origin backup"
          CONF
        end
      end

      context 'with commit options to quote' do
        let(:params) { { git_commit_options: '--author "A $USER" `x` \\' } }

        it { is_expected.to contain_file('/etc/etckeeper/etckeeper.conf').with_content(%r{^GIT_COMMIT_OPTIONS="--author \\"A \\\$USER\\" \\`x\\` \\\\"$}) }
      end

      {
        'git' => [
          'export GIT_AUTHOR_NAME="Alice"',
          'export GIT_AUTHOR_EMAIL="alice@example.com"',
          'export GIT_COMMITTER_NAME="Alice"',
          'export GIT_COMMITTER_EMAIL="alice@example.com"',
        ],
        'hg' => ['export HGUSER="Alice <alice@example.com>"'],
        'bzr' => ['export EMAIL="Alice <alice@example.com>"'],
      }.each do |vcs, lines|
        context "with the identity of the commits and vcs => #{vcs}" do
          let(:params) { { vcs: vcs, vcs_user_name: 'Alice', vcs_user_email: 'alice@example.com' } }

          it 'exports it from etckeeper.conf' do
            is_expected.to contain_file('/etc/etckeeper/etckeeper.conf')
              .with_content(%r{\n\n# Identity of the commits, instead of the user running etckeeper\.\n#{Regexp.escape(lines.join("\n"))}\n\z})
          end
        end
      end

      context 'with the identity of the commits and vcs => darcs' do
        let(:params) { { vcs: 'darcs', vcs_user_name: 'Alice', vcs_user_email: 'alice@example.com' } }

        it { is_expected.to contain_file('/etc/etckeeper/etckeeper.conf').without_content(%r{Identity|export}) }
      end

      context 'with only the name of the commits' do
        let(:params) { { vcs_user_name: 'Alice' } }

        it { is_expected.to contain_file('/etc/etckeeper/etckeeper.conf').without_content(%r{Identity|export}) }
      end
    end
  end
end
