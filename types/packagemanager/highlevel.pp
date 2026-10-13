# @summary A HIGHLEVEL_PACKAGE_MANAGER known to etckeeper.
#
# @since 1.0.0
type Etckeeper::PackageManager::HighLevel = Enum['apk', 'apt', 'cave', 'dnf', 'emerge', 'pacman', 'pacman-g2', 'xbps', 'yum', 'zypper']
