# @summary Manages the systemd timer of the daily autocommits.
#
# @api private
class etckeeper::service {
  assert_private()

  if $etckeeper::daily_autocommit_timer =~ Boolean {
    service { 'etckeeper.timer':
      ensure => bool2str($etckeeper::daily_autocommit_timer, 'running', 'stopped'),
      enable => $etckeeper::daily_autocommit_timer,
    }
  }
}
