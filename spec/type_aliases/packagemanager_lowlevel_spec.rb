# frozen_string_literal: true

require 'spec_helper'

describe 'Etckeeper::PackageManager::LowLevel' do
  it { is_expected.to allow_values('apk', 'cave', 'dpkg', 'pacman', 'pacman-g2', 'pacmatic', 'qlist', 'rpm', 'xbps') }
  it { is_expected.not_to allow_values('apt', 'dnf', 'invalid', '', 123, ['rpm'], nil) }
end
