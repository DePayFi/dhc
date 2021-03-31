# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  include ActionDispatch::TestProcess

  context 'form' do
    it 'formats requests to be application/x-www-form-urlencoded' do
      stub = stub_request(:post, 'http://depay.fi/')
        .with(body: 'client_id=1234&client_secret=4567&grant_type=client_credentials')
        .with(headers: { 'Content-Type': 'application/x-www-form-urlencoded' })
        .to_return(status: 200)

      DHC.form.post(
        'http://depay.fi',
        body: {
          client_id: '1234',
          client_secret: '4567',
          grant_type: 'client_credentials'
        }
      )

      expect(stub).to have_been_requested
    end
  end
end
