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

  if $vcs == 'git' {
    file { '/etc/.git/config':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Exec['etckeeper init'],
    }

    if $etckeeper::vcs_user_name and $etckeeper::vcs_user_email {
      ini_setting {
        default:
          ensure  => present,
          path    => '/etc/.git/config',
          section => 'user',
          require => File['/etc/.git/config'],
          ;
        '/etc/.git/config user.name':
          setting => 'name',
          value   => $etckeeper::vcs_user_name,
          ;
        '/etc/.git/config user.email':
          setting => 'email',
          value   => $etckeeper::vcs_user_email,
          ;
      }
    }
  }
}
