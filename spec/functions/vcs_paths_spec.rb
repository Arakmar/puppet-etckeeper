# frozen_string_literal: true

require 'spec_helper'

describe 'etckeeper::vcs_paths' do
  it do
    is_expected.to run.with_params.and_return(
      'bzr' => { 'directory' => '/etc/.bzr', 'ignore_file' => '/etc/.bzrignore' },
      'darcs' => { 'directory' => '/etc/_darcs', 'ignore_file' => '/etc/.darcsignore' },
      'git' => { 'directory' => '/etc/.git', 'ignore_file' => '/etc/.gitignore' },
      'hg' => { 'directory' => '/etc/.hg', 'ignore_file' => '/etc/.hgignore' },
    )
  end
end
