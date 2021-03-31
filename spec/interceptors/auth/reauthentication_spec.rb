# frozen_string_literal: true

require 'rails_helper'

describe DHC::Auth do
  let(:initial_token) { '123456' }
  let(:refresh_token) { 'abcdef' }
  let(:options) { { bearer: initial_token, refresh_client_token: -> { refresh_token } } }
  let!(:auth_failing) do
    stub_request(:get, 'http://depay.fi')
      .with(headers: { 'Authorization' => "Bearer #{initial_token}" })
      .to_return(status: 401, body: "{}") # DHC::Unauthorized
  end
  let!(:auth_suceeding_after_recovery) do
    stub_request(:get, 'http://depay.fi')
      .with(headers: { 'Authorization' => "Bearer #{refresh_token}" })
  end

  before(:each) do
    DHC.config.interceptors = [DHC::Auth, DHC::Retry]
  end

  it "recovery is attempted" do
    DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
    # the retried request (with updated Bearer), that should work
    DHC.get(:local)
    expect(auth_suceeding_after_recovery).to have_been_made.once
  end

  it "recovery is not attempted again when the request has reauthenticated: true " do
    DHC.config.endpoint(:local, 'http://depay.fi', auth: options.merge(reauthenticated: true))
    expect { DHC.get(:local) }.to raise_error(DHC::Unauthorized)
  end

  context 'token format' do
    let(:initial_token) { 'BAsZ-98-ZZZ' }

    it 'refreshes tokens with various formats' do
      DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
      DHC.get(:local)
      expect(auth_suceeding_after_recovery).to have_been_made.once
    end
  end
end
