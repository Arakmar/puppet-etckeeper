# frozen_string_literal: true

require 'spec_helper'

describe 'etckeeper::shell_quote' do
  it { is_expected.not_to be_nil }
  it { is_expected.to run.with_params(nil).and_return('""') }
  it { is_expected.to run.with_params('').and_return('""') }
  it { is_expected.to run.with_params('-a --quiet').and_return('"-a --quiet"') }
  it { is_expected.to run.with_params(%q(it's "$HOME" `id` \\)).and_return(%q("it's \\"\\$HOME\\" \\`id\\` \\\\")) }
end
