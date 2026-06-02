# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users/list' do
    let!(:user1) { create(:user, email: 'user1@example.com', username: 'user1') }
    let!(:user2) { create(:user, email: 'user2@example.com', username: 'user2') }

    context 'when user is not authenticated' do
      it 'redirects to the login page' do
        get users_list_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user1 }

      it 'returns status 200 OK' do
        get users_list_path
        expect(response).to have_http_status(:ok)
      end

      it 'returns a JSON array of users containing id, email, and username' do
        get users_list_path
        expect(response.media_type).to eq('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.size).to eq(2)

        user_keys = json_response.first.keys
        expect(user_keys).to contain_exactly('id', 'email', 'username')

        expect(json_response).to include(
          hash_including('id' => user1.id, 'email' => user1.email, 'username' => user1.username),
          hash_including('id' => user2.id, 'email' => user2.email, 'username' => user2.username)
        )
      end
    end
  end
end
