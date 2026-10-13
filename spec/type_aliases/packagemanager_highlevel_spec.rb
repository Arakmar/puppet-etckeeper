# frozen_string_literal: true

require 'spec_helper'

describe 'Etckeeper::PackageManager::HighLevel' do
  it { is_expected.to allow_values('apk', 'apt', 'cave', 'dnf', 'emerge', 'pacman', 'pacman-g2', 'xbps', 'yum', 'zypper') }
  it { is_expected.not_to allow_values('dpkg', 'rpm', 'invalid', '', 123, ['dnf'], nil) }
end
