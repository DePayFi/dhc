# frozen_string_literal: true

require 'rails_helper'

describe DHC::Auth do
  before(:each) do
    DHC.config.interceptors = [DHC::Auth]
  end

  it 'adds body authentication to the existing request body' do
    stub_request(:post, "http://depay.fi/")
      .with(body: {
        message: 'body',
        userToken: 'dheur5hrk3'
      }.to_json)

    DHC.post('http://depay.fi', auth: { body: { userToken: 'dheur5hrk3' } }, body: {
               message: 'body'
             })
  end

  it 'adds body authentication to an empty request body' do
    stub_request(:post, "http://depay.fi/")
      .with(body: {
        userToken: 'dheur5hrk3'
      }.to_json)

    DHC.post('http://depay.fi', auth: { body: { userToken: 'dheur5hrk3' } })
  end

  it 'adds nothing if request method is GET' do
    stub_request(:get, "http://depay.fi/")

    DHC.get('http://depay.fi', auth: { body: { userToken: 'dheur5hrk3' } })
  end
end
