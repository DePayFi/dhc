# frozen_string_literal: true

require 'rails_helper'

describe DHC::Error do
  context 'response' do
    it 'throws timeout exception in case of a timeout' do
      stub_request(:any, 'depay.fi').to_return(status: 403)
      begin
        DHC.get('depay.fi')
      rescue => e
        expect(e.response).to be_kind_of(DHC::Response)
        expect(e.response.code).to eq 403
      end
    end
  end
end
