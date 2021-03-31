# frozen_string_literal: true

require 'spec_helper'

describe DHC::Request do
  before do
    Object.send(:remove_const, :Rails)
    DHC.send(:remove_const, :Request)
    load('dhc/concerns/dhc/request/user_agent_concern.rb')
    load('dhc/request.rb')
  end

  context 'default headers' do
    context 'agent' do
      it 'sets header agent information to be DHC' do
        stub_request(:get, "http://depay.fi/")
          .with(
            headers: {
              'User-Agent' => "DHC (#{DHC::VERSION}) [https://github.com/DePayFi/dhc]"
            }
          )
          .to_return(status: 200)
        DHC.get('http://depay.fi')
      end
    end
  end
end
