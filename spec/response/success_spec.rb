# frozen_string_literal: true

require 'rails_helper'

describe DHC::Response do
  context 'success?' do
    let(:response_success) { DHC::Response.new(Typhoeus::Response.new(response_code: 200, mock: true), nil) }
    let(:response_error) { DHC::Response.new(Typhoeus::Response.new(response_code: 404, mock: true), nil) }

    it { expect(response_success).to be_success }
    it { expect(response_error).not_to be_success }
  end
end
