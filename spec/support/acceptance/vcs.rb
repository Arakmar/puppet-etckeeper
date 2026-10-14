# frozen_string_literal: true

# The package of each VCS, the VCS name when the package of an OS family is
# not listed, the OS that do not package it (an OS family, a family and major
# release or an OS name and release) and how the acceptance tests inspect the
# repository of /etc.
module EtckeeperAcceptance
  VCS = {
    'git' => {
      package: 'git',
      directory: '/etc/.git',
      ignore_file: '/etc/.gitignore',
      ignore_line: '\\#ignored*',
      tracked_files: 'git -C /etc ls-files',
      log: 'git -C /etc log --format=%s',
      last_commit_identity: 'git -C /etc log -1 --format="%an <%ae> / %cn <%ce>"',
      identity: 'Puppet <puppet@example.com> / Puppet <puppet@example.com>',
    },
    'hg' => {
      package: 'mercurial',
      directory: '/etc/.hg',
      ignore_file: '/etc/.hgignore',
      ignore_line: 'glob:\\#ignored*',
      tracked_files: 'hg --cwd /etc files',
      log: 'hg --cwd /etc log --template "{desc}\\n"',
      last_commit_identity: 'hg --cwd /etc log --limit 1 --template "{author}\\n"',
      identity: 'Puppet <puppet@example.com>',
    },
    'bzr' => {
      package: { 'Archlinux' => 'breezy' },
      unpackaged_on: ['RedHat'],
      directory: '/etc/.bzr',
      ignore_file: '/etc/.bzrignore',
      ignore_line: '[#]ignored*',
      tracked_files: 'cd /etc && bzr ls --versioned --recursive',
      log: 'cd /etc && bzr log --line',
      last_commit_identity: 'cd /etc && bzr log --limit 1 --log-format long | sed -n "s/^committer: //p"',
      identity: 'Puppet <puppet@example.com>',
      # The {clean} keyword of breezy, which `etckeeper unclean` relies on,
      # is always 0
      unclean_works: false,
    },
    'darcs' => {
      package: 'darcs',
      unpackaged_on: ['RedHat 8', 'Ubuntu 24.04'],
      directory: '/etc/_darcs',
      ignore_file: '/etc/.darcsignore',
      ignore_line: '(^|/)#ignored',
      tracked_files: 'cd /etc && darcs show files',
      log: 'cd /etc && darcs log',
      # darcs records the user running etckeeper
      last_commit_identity: nil,
    },
  }.freeze

  # The OS of the host as unpackaged_on names it
  def self.os
    @os ||= [
      fact('os.family'),
      "#{fact('os.family')} #{fact('os.release.major')}",
      "#{fact('os.name')} #{fact('os.release.full')}",
    ]
  end

  # Whether the OS of the host packages a VCS. The hosts are set up when the
  # specs are loaded, so this can choose the examples to define.
  def self.packaged?(vcs)
    (VCS.fetch(vcs).fetch(:unpackaged_on, []) & os).empty?
  end

  # Whether the package manager of the host can install a package.

  def package_available?(package)
    command = case fact('os.family')
              when 'Debian' then "apt-get install --simulate --quiet #{package}"
              when 'RedHat' then "dnf --quiet info #{package}"
              when 'Archlinux' then "pacman -Si #{package}"
              else raise "Unsupported OS family #{fact('os.family')}"
              end
    shell(command, acceptable_exit_codes: (0..255)).exit_code.zero?
  end
end

RSpec.configure do |c|
  c.include EtckeeperAcceptance
end
