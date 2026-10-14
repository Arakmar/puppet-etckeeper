# @summary A LOWLEVEL_PACKAGE_MANAGER known to etckeeper.
#
# @since 1.0.0
type Etckeeper::PackageManager::LowLevel = Enum['apk', 'cave', 'dpkg', 'pacman', 'pacman-g2', 'pacmatic', 'qlist', 'rpm', 'xbps']
