# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  include ActionDispatch::TestProcess

  context 'plain' do
    let(:file) { Rack::Test::UploadedFile.new(Tempfile.new) }

    it 'leaves plains requests unformatted' do
      stub_request(:post, 'http://depay.fi/')
        .with(body: /file=%23%3CRack%3A%3ATest%3A%3AUploadedFile%3.*%3E&type=Image/)
        .to_return do |request|
          expect(request.headers['Content-Type']).to be_blank

          { status: 204 }
        end
      response = DHC.plain.post(
        'http://depay.fi',
        body: { file: file, type: 'Image' }
      )
      expect(lambda {
        response.body
        response.data
      }).not_to raise_error
    end
  end
end
