# @summary The repository directory and ignore file of each VCS in /etc.
#
# @api private
#
# @return [Hash[Etckeeper::VCS, Struct[{ 'directory' => Stdlib::Absolutepath, 'ignore_file' => Stdlib::Absolutepath }]]]
#   The paths, by VCS.
function etckeeper::vcs_paths() >> Hash[Etckeeper::VCS, Struct[{ 'directory' => Stdlib::Absolutepath, 'ignore_file' => Stdlib::Absolutepath }]] {
  {
    'bzr'   => { 'directory' => '/etc/.bzr', 'ignore_file' => '/etc/.bzrignore' },
    'darcs' => { 'directory' => '/etc/_darcs', 'ignore_file' => '/etc/.darcsignore' },
    'git'   => { 'directory' => '/etc/.git', 'ignore_file' => '/etc/.gitignore' },
    'hg'    => { 'directory' => '/etc/.hg', 'ignore_file' => '/etc/.hgignore' },
  }
}
