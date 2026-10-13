# @summary Initialises the repository of /etc.
#
# etckeeper picks the VCS of the repository it finds in /etc before the one
# of its configuration, so the repositories and ignore files of the other
# VCS are removed, with their history.
#
# The ignore file and the patterns of etckeeper::ignore are written before
# `etckeeper init` adds the files of /etc, which are then committed like the
# etckeeper package of Debian does when it initialises the repository
# itself, before any of them.
#
# @api private
class etckeeper::repository {
  assert_private()

  $vcs = $etckeeper::vcs
  $paths = etckeeper::vcs_paths()
  $path = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']

  $paths.each |Etckeeper::VCS $other_vcs, Hash $other_paths| {
    if $other_vcs != $vcs {
      file { $other_paths['directory']:
        ensure => absent,
        force  => true,
        before => Exec['etckeeper init'],
      }

      file { $other_paths['ignore_file']:
        ensure => absent,
        before => Exec['etckeeper init'],
      }
    }
  }

  if $etckeeper::manage_vcs_package {
    Package[$etckeeper::vcs_packages[$vcs]] -> Exec['etckeeper init']
  }

  # Created before the repository, so that the patterns of etckeeper::ignore
  # apply to the files `etckeeper init` adds. etckeeper then appends its own
  # section to the file.
  file { $paths[$vcs]['ignore_file']:
    ensure => file,
    before => Exec['etckeeper init'],
  }

  exec { 'etckeeper init':
    command => 'etckeeper init',
    creates => $paths[$vcs]['directory'],
    cwd     => '/etc',
    path    => $path,
  }

  exec { 'etckeeper commit':
    command     => 'etckeeper commit "Initial commit"',
    cwd         => '/etc',
    path        => $path,
    refreshonly => true,
    subscribe   => Exec['etckeeper init'],
  }
}
