# @summary Ignores a glob in the repository of /etc.
#
# The pattern is appended to the ignore file of the VCS, after the section
# etckeeper manages, and written in its syntax like etckeeper writes its own
# patterns (see the `etckeeper::ignore_pattern` function). Ignoring a path
# does not remove it from the repository if it is already tracked.
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

  # Relying on this to always append to the bottom of the file
  file_line { "${ignore_file} ${glob}":
    ensure  => $ensure,
    path    => $ignore_file,
    line    => etckeeper::ignore_pattern($etckeeper::vcs, $glob),
    require => Class['etckeeper::repository'],
  }
}
