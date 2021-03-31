# frozen_string_literal: true

require 'rails_helper'

describe DHC::Request do
  context 'ignoring DHC::NotFound' do
    let(:response) { DHC.get('http://depay.fi', ignore: [DHC::NotFound]) }

    before { stub_request(:get, 'http://depay.fi').to_return(status: 404) }

    it 'does not raise an error' do
      expect { response }.not_to raise_error
    end

    it 'body is nil' do
      expect(response.body).to eq nil
    end

    it 'data is nil' do
      expect(response.data).to eq nil
    end

    it 'does raise an error for 500' do
      stub_request(:get, 'http://depay.fi').to_return(status: 500)
      expect { response }.to raise_error DHC::InternalServerError
    end

    it 'provides the information if the error was ignored' do
      expect(response.error_ignored?).to eq true
      expect(response.request.error_ignored?).to eq true
    end
  end

  context 'inheritance when ignoring errors' do
    before { stub_request(:get, 'http://depay.fi').to_return(status: 404) }

    it "does not raise an error when it's a subclass of the ignored error" do
      expect {
        DHC.get('http://depay.fi', ignore: [DHC::Error])
      }.not_to raise_error
    end

    it "does raise an error if it's not a subclass of the ignored error" do
      expect {
        DHC.get('http://depay.fi', ignore: [ArgumentError])
      }.to raise_error(DHC::NotFound)
    end
  end

  context 'does not raise exception if ignored errors is set to nil' do
    before { stub_request(:get, 'http://depay.fi').to_return(status: 404) }

    it 'does not raise an error when ignored errors is set to array with nil' do
      expect {
        DHC.get('http://depay.fi', ignore: [nil])
      }.to raise_error(DHC::NotFound)
    end

    it 'does not raise an error when ignored errors is set to nil' do
      expect {
        DHC.get('http://depay.fi', ignore: nil)
      }.to raise_error(DHC::NotFound)
    end
  end

  context 'passing keys instead of arrays' do
    before { stub_request(:get, 'http://depay.fi').to_return(status: 404) }

    it 'does not raise an error when ignored errors is a key instead of an array' do
      DHC.get('http://depay.fi', ignore: DHC::NotFound)
    end
  end
end
