# frozen_string_literal: true

require 'rails_helper'

describe DHC::Request do
  context 'timeouts' do
    it 'has no_signal options set to true by default' do
      expect_any_instance_of(Ethon::Easy).to receive(:http_request).with(anything, anything, hash_including(nosignal: true)).and_call_original
      stub_request(:get, 'http://depay.fi/')
      DHC.get('http://depay.fi')
    end
  end
end
