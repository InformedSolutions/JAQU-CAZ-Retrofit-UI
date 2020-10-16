# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - GET #reset', type: :request do
  let(:user) { User.new }

  subject { get reset_passwords_path }

  it 'returns 200' do
    subject
    expect(response).to be_successful
  end

  it 'sets password_reset_token' do
    subject
    expect(session[:password_reset_token]).not_to be_nil
  end
end
