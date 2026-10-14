# frozen_string_literal: true

require 'spec_helper'

describe 'etckeeper::ignore' do
  let(:title) { '#test*' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'without the etckeeper class' do
        it { is_expected.to compile.and_raise_error(%r{must include the etckeeper base class}) }
      end

      {
        'git' => ['/etc/.gitignore', '\#test*'],
        'hg' => ['/etc/.hgignore', 'glob:\#test*'],
        'bzr' => ['/etc/.bzrignore', '[#]test*'],
        'darcs' => ['/etc/.darcsignore', '(^|/)#test'],
      }.each do |vcs, (ignore_file, line)|
        context "with vcs => #{vcs}" do
          let(:pre_condition) { "class { 'etckeeper': vcs => '#{vcs}' }" }

          it { is_expected.to compile.with_all_deps }

          it do
            is_expected.to contain_file_line("#{ignore_file} #test*")
              .with_ensure('present')
              .with_path(ignore_file)
              .with_line(line)
              .that_requires("File[#{ignore_file}]")
              .that_comes_before('Exec[etckeeper init]')
          end
        end
      end

      context 'when absent, with another glob than the title' do
        let(:pre_condition) { 'include etckeeper' }
        let(:params) { { ensure: 'absent', glob: '*.swp' } }

        it { is_expected.to contain_file_line('/etc/.gitignore *.swp').with_ensure('absent').with_line('*.swp') }
      end
    end
  end
end
