# @summary Ignores a glob in the repository of /etc.
#
# The pattern is added to the ignore file of the VCS, in its syntax (see
# the `etckeeper::ignore_pattern` function). When the module initialises the
# repository, the pattern is in place before the files of /etc are added;
# later, it is appended after the section etckeeper manages. Ignoring a path
# does not remove it from the repository if it is already tracked, which is
# the case of the files present when the etckeeper package of Debian and
# Ubuntu initialises the repository itself.
#
# As it comes before `etckeeper init`, it cannot be ordered after
# `Class['etckeeper']`.
#
# @example Ignoring an example pattern
#   etckeeper::ignore { '*.foo':
#     ensure => present,
#   }
#
# @example Ignoring a directory
#   etckeeper::ignore { '/puppetlabs/code/environments/': }
#
# @param ensure
#   Whether the pattern is in the ignore file.
# @param glob
#   The glob to ignore.
#
# @see puppet_classes::etckeeper etckeeper
#
# @since 1.2.0
define etckeeper::ignore (
  Enum['present', 'absent'] $ensure = 'present',
  String[1]                 $glob   = $title,
) {
  unless defined(Class['etckeeper']) {
    fail('You must include the etckeeper base class before using any etckeeper defined resources')
  }

  $ignore_file = etckeeper::vcs_paths()[$etckeeper::vcs]['ignore_file']

  file_line { "${ignore_file} ${glob}":
    ensure  => $ensure,
    path    => $ignore_file,
    line    => etckeeper::ignore_pattern($etckeeper::vcs, $glob),
    require => File[$ignore_file],
    before  => Exec['etckeeper init'],
  }
}
