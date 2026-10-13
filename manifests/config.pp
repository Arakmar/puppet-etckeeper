# @summary Writes the configuration of etckeeper.
#
# @api private
class etckeeper::config {
  assert_private()

  file { $etckeeper::conf_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${etckeeper::conf_dir}/etckeeper.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('etckeeper/etckeeper.conf.epp', {
        'vcs'                         => $etckeeper::vcs,
        'git_commit_options'          => $etckeeper::git_commit_options,
        'hg_commit_options'           => $etckeeper::hg_commit_options,
        'bzr_commit_options'          => $etckeeper::bzr_commit_options,
        'darcs_commit_options'        => $etckeeper::darcs_commit_options,
        'avoid_daily_autocommits'     => $etckeeper::avoid_daily_autocommits,
        'avoid_special_file_warning'  => $etckeeper::avoid_special_file_warning,
        'avoid_commit_before_install' => $etckeeper::avoid_commit_before_install,
        'highlevel_package_manager'   => $etckeeper::highlevel_package_manager,
        'lowlevel_package_manager'    => $etckeeper::lowlevel_package_manager,
        'push_remotes'                => $etckeeper::push_remotes,
    }),
  }
}
