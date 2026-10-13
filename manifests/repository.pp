# @summary Initialises the repository of /etc.
#
# etckeeper picks the VCS of the repository it finds in /etc before the one
# of its configuration, so the repositories and ignore files of the other
# VCS are removed, with their history.
#
# @api private
class etckeeper::repository {
  assert_private()

  $vcs = $etckeeper::vcs
  $paths = etckeeper::vcs_paths()

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

  exec { 'etckeeper init':
    command => 'etckeeper init',
    creates => $paths[$vcs]['directory'],
    cwd     => '/etc',
    path    => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
  }
}
