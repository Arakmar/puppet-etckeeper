# frozen_string_literal: true

require 'spec_helper'

describe 'etckeeper::ignore_pattern' do
  it { is_expected.not_to be_nil }
  it { is_expected.to run.with_params('git', '').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('svn', '*.swp').and_raise_error(ArgumentError) }

  context 'with git' do
    it { is_expected.to run.with_params('git', '*.dpkg-*').and_return('*.dpkg-*') }
    it { is_expected.to run.with_params('git', '#*#').and_return('\#*\#') }
  end

  context 'with hg' do
    it { is_expected.to run.with_params('hg', '*.dpkg-*').and_return('glob:*.dpkg-*') }
    it { is_expected.to run.with_params('hg', '#*#').and_return('glob:\#*\#') }
  end

  context 'with bzr' do
    it { is_expected.to run.with_params('bzr', '*.dpkg-*').and_return('*.dpkg-*') }
    it { is_expected.to run.with_params('bzr', '#*#').and_return('[#]*#') }
  end

  # The patterns etckeeper writes itself for darcs
  context 'with darcs' do
    it { is_expected.to run.with_params('darcs', '*.dpkg-*').and_return('\.dpkg-') }
    it { is_expected.to run.with_params('darcs', '*.old').and_return('\.old($|/)') }
    it { is_expected.to run.with_params('darcs', '._cfg*').and_return('(^|/)\._cfg') }
    it { is_expected.to run.with_params('darcs', 'blkid.tab').and_return('(^|/)blkid\.tab($|/)') }
    it { is_expected.to run.with_params('darcs', 'network/run').and_return('(^|/)network/run($|/)') }
    it { is_expected.to run.with_params('darcs', '*.new-*_[0-9]*').and_return('\.new-[^/]*_[0-9]') }
    it { is_expected.to run.with_params('darcs', 'a?b*c').and_return('(^|/)a[^/]b[^/]*c($|/)') }
    it { is_expected.to run.with_params('darcs', '*').and_return('(^|/)') }
    it { is_expected.to run.with_params('darcs', '#*#').and_return('(^|/)#[^/]*#($|/)') }
    it { is_expected.to run.with_params('darcs', '*#').and_return('\#($|/)') }
  end
end
