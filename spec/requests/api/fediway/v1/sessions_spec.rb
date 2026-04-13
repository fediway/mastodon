# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fediway sessions bridge' do
  describe 'POST /api/fediway/v1/sessions/bridge' do
    subject { post '/api/fediway/v1/sessions/bridge', headers: headers }

    let(:user) { Fabricate(:user) }
    let(:application) { Fabricate(:application) }
    let(:token) { Fabricate(:accessible_access_token, application: application, resource_owner_id: user.id, scopes: 'read') }
    let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

    context 'without a token' do
      let(:headers) { {} }

      it 'returns 401' do
        subject
        expect(response).to have_http_status(401)
      end
    end

    context 'with a valid token' do
      it 'returns 200' do
        subject
        expect(response).to have_http_status(200)
      end

      it 'sets a session cookie' do
        subject
        expect(response.headers['Set-Cookie'].to_s).to include('session')
      end
    end

    context 'when the user is disabled' do
      before { user.update!(disabled: true) }

      it 'returns 403' do
        subject
        expect(response).to have_http_status(403)
      end
    end
  end
end
