# etckeeper

[![CI](https://github.com/Arakmar/puppet-etckeeper/actions/workflows/ci.yml/badge.svg)](https://github.com/Arakmar/puppet-etckeeper/actions/workflows/ci.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/arakmar/etckeeper.svg)](https://forge.puppet.com/modules/arakmar/etckeeper)

## Table of contents

1. [Description](#description)
1. [Setup](#setup)
    * [What etckeeper affects](#what-etckeeper-affects)
    * [Requirements](#requirements)
    * [Beginning with etckeeper](#beginning-with-etckeeper)
1. [Usage](#usage)
    * [Choosing the VCS](#choosing-the-vcs)
    * [Identity of the commits](#identity-of-the-commits)
    * [Ignoring files](#ignoring-files)
    * [Hiera](#hiera)
1. [Upgrading from bodgit-etckeeper](#upgrading-from-bodgit-etckeeper)
1. [Limitations](#limitations)
1. [Development](#development)

## Description

This module keeps `/etc` under version control with
[etckeeper](https://etckeeper.branchable.com/): it installs etckeeper and the
VCS it uses (git, Mercurial, Bazaar/Breezy or darcs), writes
`etckeeper.conf` and initialises the repository of `/etc`.

etckeeper then commits the changes of `/etc` before and after each package
installation, through the hooks of the package manager, and once a day.

## Setup

### What etckeeper affects

* The `etckeeper` package and the package of the VCS.
* `/etc/etckeeper/etckeeper.conf`.
* The repository of `/etc` (`/etc/.git`, `/etc/.hg`, `/etc/.bzr` or
  `/etc/_darcs`) and its ignore file.

etckeeper uses the repository it finds in `/etc` whatever its
configuration, so the module removes the repositories and ignore files of the
other VCS: **switching to another VCS loses the history of the previous
one.**

### Requirements

* Puppet 8 or OpenVox 8.
* [puppetlabs/stdlib](https://forge.puppet.com/modules/puppetlabs/stdlib) 9.x
  or 10.x.
* On EL, the [EPEL](https://docs.fedoraproject.org/en-US/epel/) repository,
  for instance from [puppet/epel](https://forge.puppet.com/modules/puppet/epel).

The module is tested on EL 8 to 10 (RHEL, CentOS Stream, Rocky, AlmaLinux),
Debian 12 and 13, Ubuntu 22.04 and 24.04 and Arch Linux. Its data also covers
SUSE (zypper), untested.

### Beginning with etckeeper

```puppet
include etckeeper
```

This keeps `/etc` in git. On Debian and Ubuntu, the etckeeper package
initialises the repository and commits `/etc` when it is installed; on the
other distributions, the module initialises the repository.

## Usage

### Choosing the VCS

```puppet
class { 'etckeeper':
  vcs => 'hg',
}
```

The module installs the package of the VCS from `vcs_packages`, merged with
the module data (Breezy provides `bzr` on Arch Linux). It is declared with
`stdlib::ensure_packages`, so it does not clash with another
`stdlib::ensure_packages(['git'])`; set `manage_vcs_package => false` when it
is installed otherwise. Bazaar is not packaged for EL, nor darcs for EL 8 and
Ubuntu 24.04.

The options of etckeeper.conf are parameters: the options of the commits for
each VCS, the `AVOID_*` switches and the remotes each commit is pushed to:

```puppet
class { 'etckeeper':
  git_commit_options      => '--quiet',
  avoid_daily_autocommits => true,
  push_remotes            => ['origin'],
}
```

The package managers default to those of the OS family: apt/dpkg on Debian,
dnf/rpm on EL, pacman on Arch Linux.

### Identity of the commits

By default, etckeeper commits as the user running it, or the user behind
sudo, with the name and email of their git configuration when they have
one. `vcs_user_name` and `vcs_user_email` replace this identity for every
commit:

```puppet
class { 'etckeeper':
  vcs_user_name  => 'etckeeper',
  vcs_user_email => 'root@example.com',
}
```

`etckeeper.conf` exports them as the git author and committer, or in
`HGUSER` and `EMAIL` for hg and bzr. They are only used together, and darcs
always records the user running etckeeper.

### Ignoring files

```puppet
etckeeper::ignore { '/puppetlabs/code/environments/': }
etckeeper::ignore { '*.swp': }
```

The glob is written in the syntax of the ignore file of the VCS, as etckeeper
writes its own patterns. When the module initialises the repository, the
patterns are in place before etckeeper adds the files of `/etc`. A file
already tracked is not removed from the repository, for instance one present
when the Debian package initialised it:

```puppet
exec { 'etckeeper-untrack-r10k-environments':
  command => 'etckeeper vcs rm -r -q --cached puppetlabs/code/environments',
  onlyif  => 'test -n "$(etckeeper vcs ls-files puppetlabs/code/environments)"',
  cwd     => '/etc',
  path    => ['/usr/bin', '/bin'],
  require => Etckeeper::Ignore['/puppetlabs/code/environments/'],
}
```

### Hiera

```yaml
etckeeper::vcs: 'git'
etckeeper::vcs_user_name: 'etckeeper'
etckeeper::vcs_user_email: 'root@example.com'
etckeeper::vcs_packages:
  git: 'git-core'
```

## Upgrading from bodgit-etckeeper

Version 3.0.0 follows bodgit-etckeeper 2.0.0, which is no longer maintained,
under the name `arakmar-etckeeper`. It needs Puppet 8 and stdlib 9 or later,
and no longer uses puppetlabs/inifile.

| Before                                                              | Now                                                                                   |
|---------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| `vcs_user_name` and `vcs_user_email` in `/etc/.git/config`, which etckeeper mostly overrides | exported from `etckeeper.conf`, for the author and the committer, and for hg and bzr |
| `avoid_*` undef by default                                          | `false` by default, which renders the same file                                        |
| `push_remotes` undef by default                                     | `[]`                                                                                   |
| `git_commit_options`, `hg_commit_options`, `bzr_commit_options` accept `''` | undef or a non empty string                                                    |
| `highlevel_package_manager` `yum` on EL                             | `dnf`, which EL 8 and later use                                                        |
| `bzr` package on Arch Linux                                         | `breezy`                                                                               |
| `vcs` defaulted to `bzr` on Ubuntu 14.04                            | `git` everywhere                                                                       |
| `etckeeper::ignore` lines `\#glob` (hg) and `#glob` (bzr)           | `glob:\#glob` and `[#]glob`, which do not depend on their position                    |
| mode of `/etc/.git/config` forced to 0644                           | left to git                                                                            |

The `etckeeper::ignore` lines written by the previous version stay in the
ignore files. With hg, and bzr for the globs starting with `#`, the new lines
are added next to them.

## Limitations

* The module only manages the repository of `/etc`.
* The VCS cannot be switched without losing the history of the previous one.
* `etckeeper::ignore` does not remove the files already tracked from the
  repository.
* With Breezy, `etckeeper unclean` always reports changes in `/etc`.

## Development

```
pdk validate
pdk test unit
pdk bundle exec rake strings:generate:reference
```

The acceptance tests run with
[voxpupuli-acceptance](https://github.com/voxpupuli/voxpupuli-acceptance) in
containers:

```
pdk bundle config set --local with system_tests
BEAKER_SETFILE=debian12-64 pdk bundle exec rspec spec/acceptance
```

GitHub Actions run the static validations, RuboCop, a REFERENCE.md freshness
check and the unit tests on every pull request and push to `master`, and the
acceptance tests on each supported OS with OpenVox 8 (Arch Linux with its own
Puppet package), the matrices being built from `metadata.json`
(`.github/workflows/ci.yml`, modelled on the
[Vox Pupuli](https://github.com/voxpupuli/gha-puppet) workflows).

Pushing a `v<version>` tag runs the same CI on the tagged commit, checks that
the tag matches the version of `metadata.json`, then publishes the module to
the Puppet Forge and creates a GitHub release through the Vox Pupuli reusable
release workflow (`.github/workflows/release.yml`). The repository needs a
`release` environment and the `PUPPET_FORGE_USERNAME` and
`PUPPET_FORGE_API_KEY` secrets; bump `metadata.json` to the tagged version
first.

This module is licensed under the Apache-2.0 license, see
[LICENSE](LICENSE). It was written by Matt Dainty
([bodgit](https://github.com/bodgit/puppet-etckeeper)).
