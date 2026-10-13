# @summary Installs etckeeper and the package of the VCS.
#
# @api private
class etckeeper::install {
  assert_private()

  package { $etckeeper::package_name:
    ensure => installed,
  }

  if $etckeeper::manage_vcs_package {
    unless $etckeeper::vcs in $etckeeper::vcs_packages {
      fail("etckeeper: no package is known for the VCS ${etckeeper::vcs}, see the vcs_packages parameter")
    }

    # ensure_packages, as the VCS is often installed by other classes too
    stdlib::ensure_packages([$etckeeper::vcs_packages[$etckeeper::vcs]])
  }
}
