# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fediway credentials login' do
  describe 'POST /api/fediway/v1/credentials' do
    subject { post '/api/fediway/v1/credentials', params: params, as: :json }

    let(:user) { Fabricate(:user, password: 'P@ssword12345') }
    let(:params) { { email: user.email, password: 'P@ssword12345' } }

    context 'with valid credentials' do
      it 'returns 200' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'sets a session cookie' do
        subject
        expect(response.headers['Set-Cookie'].to_s).to match(/session/i)
      end
    end

    context 'with the wrong password' do
      let(:params) { super().merge(password: 'wrong-password') }

      it 'returns 401 with invalid_credentials' do
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body[:error]).to eq('invalid_credentials')
      end
    end

    context 'with an unknown email' do
      let(:params) { super().merge(email: 'nobody@example.test') }

      it 'returns 401 with invalid_credentials (no account enumeration)' do
        subject
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body[:error]).to eq('invalid_credentials')
      end
    end

    context 'when the user has 2FA enabled' do
      before { user.update!(otp_required_for_login: true, otp_secret: User.generate_otp_secret) }

      it 'returns 403 with two_factor_required' do
        subject
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body[:error]).to eq('two_factor_required')
      end
    end

    context 'when the user is unconfirmed' do
      before { user.update!(confirmed_at: nil) }

      it 'returns 403 with unconfirmed' do
        subject
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body[:error]).to eq('unconfirmed')
      end
    end

    context 'when the user is unapproved' do
      before { user.update!(approved: false) }

      it 'returns 403 with unapproved' do
        subject
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body[:error]).to eq('unapproved')
      end
    end

    context 'when the user is disabled' do
      before { user.update!(disabled: true) }

      it 'returns 403 with disabled' do
        subject
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body[:error]).to eq('disabled')
      end
    end
  end
end
