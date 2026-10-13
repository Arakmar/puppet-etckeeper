# @summary Keeps /etc under version control with etckeeper.
#
# Installs etckeeper and the VCS it uses, writes etckeeper.conf and
# initialises the repository of /etc. The package manager hooks of
# etckeeper then commit the changes around each package installation, and
# its daily cron job commits the others.
#
# @example Declaring the class
#   include etckeeper
#
# @example Choosing a specific VCS instead of the default
#   class { 'etckeeper':
#     vcs => 'hg',
#   }
#
# @example Forcing the user name & email for commits
#   class { 'etckeeper':
#     vcs_user_name  => 'Alice',
#     vcs_user_email => 'alice@example.com',
#   }
#
# @param vcs
#   The VCS keeping /etc. Switching to another VCS removes the repository of
#   the previous one, with its history.
# @param package_name
#   The etckeeper package.
# @param manage_vcs_package
#   Whether to install the package of the VCS, from `vcs_packages`. It is
#   declared with `stdlib::ensure_packages`, so an identical declaration
#   elsewhere does not clash with it.
# @param vcs_packages
#   The package providing each VCS. Merged with the module data, which only
#   lists the names that differ by OS family.
# @param conf_dir
#   The configuration directory of etckeeper.
# @param highlevel_package_manager
#   HIGHLEVEL_PACKAGE_MANAGER: the package manager whose runs etckeeper
#   commits around. The module data sets it for each OS family.
# @param lowlevel_package_manager
#   LOWLEVEL_PACKAGE_MANAGER: the package database etckeeper lists the
#   installed packages from, and whose leftover files (`*.dpkg-*`,
#   `*.rpmnew`, `*.pacnew`...) it ignores. The module data sets it for each
#   OS family.
# @param git_commit_options
#   GIT_COMMIT_OPTIONS: options of `git commit`.
# @param hg_commit_options
#   HG_COMMIT_OPTIONS: options of `hg commit`.
# @param bzr_commit_options
#   BZR_COMMIT_OPTIONS: options of `bzr commit`.
# @param darcs_commit_options
#   DARCS_COMMIT_OPTIONS: options of `darcs record`.
# @param avoid_daily_autocommits
#   AVOID_DAILY_AUTOCOMMITS: stop the daily cron job of etckeeper from
#   committing the changes of /etc.
# @param avoid_special_file_warning
#   AVOID_SPECIAL_FILE_WARNING: do not warn about the special files of /etc
#   that the VCS cannot store.
# @param avoid_commit_before_install
#   AVOID_COMMIT_BEFORE_INSTALL: cancel the installation of packages when
#   /etc has uncommitted changes, instead of committing them first.
# @param push_remotes
#   PUSH_REMOTE: the remotes each commit is pushed to, with git or hg. They
#   must be configured in the repository.
# @param vcs_user_name
#   The name of the author of the commits, used along with `vcs_user_email`.
# @param vcs_user_email
#   The email of the author of the commits, used along with `vcs_user_name`.
#
# @see puppet_defined_types::etckeeper::ignore etckeeper::ignore
#
# @since 1.0.0
class etckeeper (
  Etckeeper::PackageManager::HighLevel $highlevel_package_manager,
  Etckeeper::PackageManager::LowLevel  $lowlevel_package_manager,
  Hash[Etckeeper::VCS, String[1]]      $vcs_packages,
  Etckeeper::VCS                       $vcs                         = 'git',
  String[1]                            $package_name                = 'etckeeper',
  Boolean                              $manage_vcs_package          = true,
  Stdlib::Absolutepath                 $conf_dir                    = '/etc/etckeeper',
  Optional[String[1]]                  $git_commit_options          = undef,
  Optional[String[1]]                  $hg_commit_options           = undef,
  Optional[String[1]]                  $bzr_commit_options          = undef,
  String[1]                            $darcs_commit_options        = '-a',
  Boolean                              $avoid_daily_autocommits     = false,
  Boolean                              $avoid_special_file_warning  = false,
  Boolean                              $avoid_commit_before_install = false,
  Array[String[1]]                     $push_remotes                = [],
  Optional[String[1]]                  $vcs_user_name               = undef,
  Optional[String[1]]                  $vcs_user_email              = undef,
) {
  contain etckeeper::install
  contain etckeeper::config
  contain etckeeper::repository

  Class['etckeeper::install'] -> Class['etckeeper::config'] -> Class['etckeeper::repository']
}
