# frozen_string_literal: true

require 'rails_helper'

describe DHC::Auth do
  let(:bearer_token) { '123456' }

  before(:each) do
    stub_request(:get, 'http://depay.fi').with(headers: { 'Authorization' => "Bearer #{bearer_token}" })
  end

  context 'configuration check not happening' do
    let(:options) { { bearer: bearer_token } }

    before(:each) { DHC.config.interceptors = [DHC::Auth, DHC::Retry] }

    it 'max_recovery_attempts is zero' do
      expect_any_instance_of(described_class).not_to receive(:warn)
      DHC.config.endpoint(:local, 'http://depay.fi', auth: options.merge(max_recovery_attempts: 0))
      DHC.get(:local)
    end

    it 'max_recovery_attempts is missing' do
      expect_any_instance_of(described_class).not_to receive(:warn)
      DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
      DHC.get(:local)
    end
  end

  context 'configuration check happening' do
    let(:options) { { bearer: bearer_token, max_recovery_attempts: 1, refresh_client_token: -> { 'here comes your refresh code' } } }

    it 'no warning with proper options' do
      DHC.config.interceptors = [DHC::Auth, DHC::Retry]
      DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
      expect_any_instance_of(described_class).not_to receive(:warn)
      DHC.get(:local)
    end

    it 'warn refresh_client_token is a string' do
      DHC.config.interceptors = [DHC::Auth, DHC::Retry]
      DHC.config.endpoint(:local, 'http://depay.fi', auth: options.merge(refresh_client_token: bearer_token))
      expect_any_instance_of(described_class).to receive(:warn).with('[WARNING] The given refresh_client_token must be a Proc for reauthentication.')
      DHC.get(:local)
    end

    it 'warn interceptors miss DHC::Retry' do
      DHC.config.interceptors = [DHC::Auth]
      DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
      expect_any_instance_of(described_class).to receive(:warn).with('[WARNING] Your interceptors must include DHC::Retry after DHC::Auth.')
      DHC.get(:local)
    end

    it 'warn interceptors DHC::Retry before DHC::Auth' do
      DHC.config.interceptors = [DHC::Retry, DHC::Auth]
      DHC.config.endpoint(:local, 'http://depay.fi', auth: options)
      expect_any_instance_of(described_class).to receive(:warn).with('[WARNING] Your interceptors must include DHC::Retry after DHC::Auth.')
      DHC.get(:local)
    end
  end
end
