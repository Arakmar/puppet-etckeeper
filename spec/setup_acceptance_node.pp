# Applied on each acceptance node before the tests: etckeeper and some of the
# VCS come from EPEL on EL.
if $facts['os']['family'] == 'RedHat' {
  package { 'epel-release':
    ensure => installed,
  }
}
