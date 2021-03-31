# frozen_string_literal: true

require 'spec_helper'

describe DHC::Request do
  before do
    allow_any_instance_of(DHC::Request).to receive(:use_configured_endpoint!)
    allow_any_instance_of(DHC::Request).to receive(:generate_url_from_template!)
  end
  context 'request without rails' do
    it 'does have deep_merge dependency met' do
      expect { DHC::Request.new({}, false) }.not_to raise_error
    end
  end
end
