# frozen_string_literal: true

require 'rails_helper'

describe DHC::Error do
  context 'timeout' do
    it 'throws timeout exception in case of a timeout' do
      stub_request(:any, 'depay.fi').to_timeout
      expect(lambda {
        DHC.get('depay.fi')
      }).to raise_error DHC::Timeout
    end
  end
end
