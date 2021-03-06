# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'formats' do
    it 'adds Content-Type, Accept and Accept-Charset Headers to the request' do
      stub_request(:get, 'http://depay.fi/')
        .with(headers: {
                'Accept' => 'application/json,application/vnd.api+json',
                'Content-Type' => 'application/json; charset=utf-8',
                'Accept-Charset' => 'utf-8'
              })
        .to_return(body: {}.to_json)
      DHC.json.get('http://depay.fi')
    end

    context 'header key as symbol' do
      it 'raises an error when trying to set content-type header even though the format is used' do
        expect(lambda {
          DHC.post(
            'http://depay.fi',
            headers: {
              'Content-Type': 'multipart/form-data'
            }
          )
        }).to raise_error 'Content-Type header is not allowed for formatted requests!\nSee https://github.com/DePayFi/dhc#formats for more information.'
      end

      it 'raises an error when trying to set accept header even though the format is used' do
        expect(lambda {
          DHC.post(
            'http://depay.fi',
            headers: {
              'Accept': 'multipart/form-data'
            }
          )
        }).to raise_error 'Accept header is not allowed for formatted requests!\nSee https://github.com/DePayFi/dhc#formats for more information.'
      end
    end

    context 'header key as string' do
      it 'raises an error when trying to set content-type header even though the format is used' do
        expect(lambda {
          DHC.post(
            'http://depay.fi',
            headers: {
              'Content-Type' => 'multipart/form-data'
            }
          )
        }).to raise_error 'Content-Type header is not allowed for formatted requests!\nSee https://github.com/DePayFi/dhc#formats for more information.'
      end

      it 'raises an error when trying to set accept header even though the format is used' do
        expect(lambda {
          DHC.post(
            'http://depay.fi',
            headers: {
              'Accept' => 'multipart/form-data'
            }
          )
        }).to raise_error 'Accept header is not allowed for formatted requests!\nSee https://github.com/DePayFi/dhc#formats for more information.'
      end
    end
  end
end
