# frozen_string_literal: true

require 'rails_helper'

describe AccessibilityStatementController, type: :request do
  describe 'GET #index' do
    subject(:http_request) { get accessibility_statement_index_path }

    it 'returns a success response' do
      http_request
      expect(response).to have_http_status(:success)
    end
  end
end
