# Changelog

All notable changes to this project will be documented in this file.

## Release 3.0.0

First release published as `arakmar-etckeeper`, following
bodgit-etckeeper 2.0.0, which is no longer maintained. See the upgrade table
of the README.

**Breaking changes**

* Puppet 8 (or OpenVox 8) and puppetlabs/stdlib 9.x or 10.x are required.
  puppetlabs/inifile is no longer used. EL 6/7, Debian 7 to 10, Ubuntu 14.04
  to 20.04 and SLES 11/12 are no longer supported; EL 8 to 10, Debian 12 and
  13, Ubuntu 22.04 and 24.04 are.
* `vcs_user_name` and `vcs_user_email` are exported from etckeeper.conf
  instead of being written to `/etc/.git/config`, so they apply to the author
  and the committer of every commit, and to hg and bzr.
* The `avoid_*` parameters are Booleans defaulting to false and
  `push_remotes` defaults to an empty array. The git, hg and bzr commit
  options no longer accept an empty string, the darcs ones are required.
* EL uses dnf as its high-level package manager, Arch Linux installs breezy
  for bzr, and Ubuntu 14.04 no longer defaults to bzr.
* `etckeeper::ignore` prefixes hg patterns with `glob:` and writes a leading
  `#` as `[#]` for bzr and `\#` for darcs.

**Features**

* `package_ensure` sets the version of the etckeeper package.
* `ignores` declares `etckeeper::ignore` resources, merged across the Hiera
  levels.
* `daily_autocommit_timer` manages the `etckeeper.timer` systemd unit, the
  only daily autocommit of Arch Linux.
* The module commits `/etc` once it has initialised the repository, like
  the package of Debian does.
* The package manager types accept every package manager etckeeper knows.
* `vcs_packages` is merged with the module data.
* The VCS package is declared with `stdlib::ensure_packages`, so another
  class can install it too.
* The values of etckeeper.conf are quoted for sh.
* puppet-strings documentation (REFERENCE.md), rspec-puppet unit tests,
  Beaker acceptance tests running every VCS in containers, GitHub Actions CI
  and Forge release workflows.

**Bugfixes**

* The commits did not carry `vcs_user_name` and `vcs_user_email`, which
  etckeeper overrides in the environment of git.
* The files matching an `etckeeper::ignore` pattern were added to the
  repository when the module initialised it, the pattern being written
  afterwards.
* A bzr pattern starting with `#` was taken for a comment.
* The configuration directory had mode 0644.

## [v2.0.0](https://github.com/bodgit/puppet-etckeeper/tree/v2.0.0) (2021-06-08)

[Full Changelog](https://github.com/bodgit/puppet-etckeeper/compare/v1.2.3...v2.0.0)

### Changed

- Drop old Puppet versions [\#17](https://github.com/bodgit/puppet-etckeeper/pull/17) ([bodgit](https://github.com/bodgit))

### Added

- Refactor to use Hiera instead of params.pp [\#21](https://github.com/bodgit/puppet-etckeeper/pull/21) ([bodgit](https://github.com/bodgit))
- Test type aliases correctly [\#20](https://github.com/bodgit/puppet-etckeeper/pull/20) ([bodgit](https://github.com/bodgit))
- Add support for latest Debian and Ubuntu releases [\#19](https://github.com/bodgit/puppet-etckeeper/pull/19) ([bodgit](https://github.com/bodgit))
- Bump dependencies [\#18](https://github.com/bodgit/puppet-etckeeper/pull/18) ([bodgit](https://github.com/bodgit))
- Convert to PDK [\#16](https://github.com/bodgit/puppet-etckeeper/pull/16) ([bodgit](https://github.com/bodgit))

## [v1.2.3](https://github.com/bodgit/puppet-etckeeper/tree/v1.2.3) (2018-05-24)

[Full Changelog](https://github.com/bodgit/puppet-etckeeper/compare/v1.2.2...v1.2.3)

### Added

- Archlinux support [\#9](https://github.com/bodgit/puppet-etckeeper/pull/9) ([Arakmar](https://github.com/Arakmar))

## [v1.2.2](https://github.com/bodgit/puppet-etckeeper/tree/v1.2.2) (2018-04-18)

[Full Changelog](https://github.com/bodgit/puppet-etckeeper/compare/v1.2.1...v1.2.2)

### Added

- Add support for SLES [\#8](https://github.com/bodgit/puppet-etckeeper/pull/8) ([mxey](https://github.com/mxey))

## [v1.2.1](https://github.com/bodgit/puppet-etckeeper/tree/v1.2.1) (2017-11-06)

[Full Changelog](https://github.com/bodgit/puppet-etckeeper/compare/v1.2.0...v1.2.1)

## [v1.2.0](https://github.com/bodgit/puppet-etckeeper/tree/v1.2.0) (2017-04-22)

[Full Changelog](https://github.com/bodgit/puppet-etckeeper/compare/v1.1.0...v1.2.0)

## [v1.1.0](https://github.com/bodgit/puppet-etckeeper/tree/v1.1.0) (2017-03-06)

[Full Changelog](https://github.com/bodgit/puppet-etckeeper/compare/v1.0.0...v1.1.0)

## [v1.0.0](https://github.com/bodgit/puppet-etckeeper/tree/v1.0.0) (2017-01-10)

[Full Changelog](https://github.com/bodgit/puppet-etckeeper/compare/16f46fde16e33d125dc64a9be4b23ea9bd9aeaa9...v1.0.0)

