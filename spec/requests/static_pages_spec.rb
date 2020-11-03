# frozen_string_literal: true

require 'rails_helper'

describe StaticPagesController, type: :request do
  before { subject }

  describe 'GET #cookies' do
    subject { get cookies_path }

    it 'returns a success response' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #accessibility_statement' do
    subject { get accessibility_statement_path }

    it 'returns a success response' do
      expect(response).to have_http_status(:success)
    end
  end
end
