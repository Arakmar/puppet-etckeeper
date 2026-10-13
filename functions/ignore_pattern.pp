# @summary Writes a glob in the syntax of the ignore file of a VCS.
#
# The glob is converted the way etckeeper converts its own patterns
# (update-ignore.d/01update-ignore), except that the line must not depend on
# its position in the file, as it may come before the section of etckeeper:
#
# * git escapes `#`, which would start a comment;
# * hg escapes `#` too and prefixes the glob with `glob:`, since the
#   `syntax: glob` line is in the section of etckeeper;
# * bzr takes the glob as is, a leading `#` becoming `[#]` not to be a
#   comment;
# * darcs, which only understands regular expressions, gets one anchored on
#   path components, unless the glob starts or ends with `*`, and a leading
#   `#` escaped.
#
# @example
#   etckeeper::ignore_pattern('git', '#*#')        # => '\#*\#'
#   etckeeper::ignore_pattern('hg', '#*#')         # => 'glob:\#*\#'
#   etckeeper::ignore_pattern('bzr', '#*#')        # => '[#]*#'
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
      $glob.regsubst(/\A#/, '[#]')
    }
    'darcs': {
      $without_trailing_star = $glob.regsubst(/\*\z/, '')
      $without_stars = $without_trailing_star.regsubst(/\A\*/, '')
      $prefix = bool2str($without_stars == $without_trailing_star, '(^|/)', '')
      $suffix = bool2str($without_trailing_star == $glob, '($|/)', '')
      "${prefix}${without_stars}${suffix}".regsubst(/\./, '\\.', 'G').regsubst(/\*/, '[^/]*', 'G').regsubst(/\?/, '[^/]', 'G').regsubst(/\A#/, '\\#')
    }
    'hg': {
      $escaped = $glob.regsubst('#', '\\#', 'G')
      "glob:${escaped}"
    }
    default: {
      $glob.regsubst('#', '\\#', 'G')
    }
  }
}
