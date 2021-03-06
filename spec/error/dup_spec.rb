# frozen_string_literal: true

require 'rails_helper'

describe DHC::Error do
  it 'does not dup' do
    options = { errors: [described_class] }
    expect(
      options.deep_dup[:errors].include?(described_class)
    ).to eq true
  end
end
