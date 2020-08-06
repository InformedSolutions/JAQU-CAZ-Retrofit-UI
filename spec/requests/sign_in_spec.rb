# frozen_string_literal: true

require 'rails_helper'

describe 'User singing in', type: :request do
  let(:email) { 'user@example.com' }
  let(:password) { '12345678' }
  let(:params) do
    {
      user: {
        username: email,
        password: password
      }
    }
  end

  describe 'signing in' do
    subject { post user_session_path(params) }

    context 'when incorrect credentials given' do
      before do
        allow(Cognito::AuthUser).to receive(:call).and_return(false)
        subject
      end

      it 'shows `The username or password you entered is incorrect` message' do
        expect(response.body).to include(I18n.t('devise.failure.invalid'))
      end
    end

    context 'when correct credentials given' do
      before do
        allow(Cognito::AuthUser).to receive(:call).and_return(User.new)
      end

      it 'logs user in' do
        subject
        expect(controller.current_user).not_to be(nil)
      end

      it 'redirects to root' do
        subject
        expect(response).to redirect_to(root_path)
      end

      it 'calls Cognito::AuthUser with proper params' do
        expect(Cognito::AuthUser)
          .to receive(:call)
          .with(username: email, password: password, login_ip: @remote_ip)
        subject
      end
    end
  end
end
