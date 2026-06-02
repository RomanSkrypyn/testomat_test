# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifications', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:notification) { create(:notification, mentioned_user: user, read: false) }
  let!(:other_notification) { create(:notification, mentioned_user: other_user, read: false) }

  describe 'POST /notifications/:id/read' do
    context 'when user is not authenticated' do
      it 'redirects to the login page' do
        post read_notification_path(notification)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      it 'marks the notification as read and redirects to root_path by default' do
        post read_notification_path(notification)
        expect(notification.reload.read).to be true
        expect(response).to redirect_to(root_path)
      end

      it 'responds with JSON indicating success if requested as JSON' do
        post read_notification_path(notification), headers: { 'ACCEPT' => 'application/json' }
        expect(notification.reload.read).to be true
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)).to eq({ 'success' => true })
      end

      it 'does not allow marking other users\' notifications as read' do
        post read_notification_path(other_notification)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /notifications/read_all' do
    context 'when user is not authenticated' do
      it 'redirects to the login page' do
        post read_all_notifications_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      it 'marks all unread notifications for the user as read' do
        create(:notification, mentioned_user: user, read: false)

        post read_all_notifications_path
        expect(user.notifications.unread.count).to eq(0)
        expect(other_notification.reload.read).to be false
        expect(response).to redirect_to(root_path)
      end

      it 'responds with JSON indicating success if requested as JSON' do
        post read_all_notifications_path, headers: { 'ACCEPT' => 'application/json' }
        expect(user.notifications.unread.count).to eq(0)
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)).to eq({ 'success' => true })
      end
    end
  end
end
