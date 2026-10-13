# @summary Writes a glob in the syntax of the ignore file of a VCS.
#
# The glob is converted the way etckeeper converts its own patterns
# (update-ignore.d/01update-ignore): git and hg escape `#`, which would
# start a comment (etckeeper sets the glob syntax in .hgignore), bzr takes
# the glob as is and darcs, which only understands regular expressions,
# gets a regular expression anchored on path components, unless the glob
# starts or ends with `*`.
#
# @example
#   etckeeper::ignore_pattern('darcs', '*.dpkg-*') # => '\.dpkg-'
#
# @param vcs
#   The VCS whose ignore file the pattern is for.
# @param glob
#   The glob to ignore.
#
# @return [String[1]]
#   The line to add to the ignore file.
#
# @since 3.0.0
function etckeeper::ignore_pattern(Etckeeper::VCS $vcs, String[1] $glob) >> String[1] {
  case $vcs {
    'bzr': {
      $glob
    }
    'darcs': {
      $without_trailing_star = $glob.regsubst(/\*\z/, '')
      $without_stars = $without_trailing_star.regsubst(/\A\*/, '')
      $prefix = bool2str($without_stars == $without_trailing_star, '(^|/)', '')
      $suffix = bool2str($without_trailing_star == $glob, '($|/)', '')
      "${prefix}${without_stars}${suffix}".regsubst(/\./, '\\.', 'G').regsubst(/\*/, '[^/]*', 'G').regsubst(/\?/, '[^/]', 'G')
    }
    default: {
      $glob.regsubst('#', '\\#', 'G')
    }
  }
}
