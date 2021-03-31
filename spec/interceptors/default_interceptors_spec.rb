# frozen_string_literal: true

require 'rails_helper'

describe DHC do
  context 'default interceptors' do
    before(:each) do
      DHC.configure {}
    end

    it 'alwayses return a list for default interceptors' do
      expect(DHC.config.interceptors).to eq []
    end
  end
end
