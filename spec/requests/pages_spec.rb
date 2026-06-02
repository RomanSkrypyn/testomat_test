# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /' do
    context 'when user is not authenticated' do
      it 'responds successfully and initializes guest variables' do
        get root_path
        expect(response).to have_http_status(:success)
        expect(controller.instance_variable_get(:@notifications)).to be_empty
        expect(controller.instance_variable_get(:@comment)).to be_a_new(Comment)
      end
    end

    context 'when user is authenticated' do
      let(:user) { create(:user) }
      let!(:notification1) { create(:notification, mentioned_user: user, created_at: 2.days.ago) }
      let!(:notification2) { create(:notification, mentioned_user: user, created_at: 1.day.ago) }

      before { sign_in user }

      it 'responds successfully and loads notifications in correct order' do
        get root_path
        expect(response).to have_http_status(:success)
        notifications = controller.instance_variable_get(:@notifications)
        expect(notifications).to eq([notification2, notification1])
        expect(controller.instance_variable_get(:@comment)).to be_a_new(Comment)
        expect(controller.instance_variable_get(:@comment).user).to eq(user)
      end
    end

    describe 'comments listing and search' do
      let!(:comment1) { create(:comment, body: 'First comment', updated_at: 2.days.ago) }
      let!(:comment2) { create(:comment, body: 'Second comment', updated_at: 1.day.ago) }

      it 'returns comments ordered by updated_at descending without query' do
        get root_path
        comments = controller.instance_variable_get(:@comments)
        expect(comments).to eq([comment2, comment1])
      end

      it 'calls Comment.search when query param is present' do
        expect(Comment).to receive(:search).with('search term', sort: ['updated_at:desc']).and_call_original
        get root_path, params: { query: 'search term' }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
