# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:user) { create(:user) }
  let!(:comment_by_user) { create(:comment, user: user, body: 'Original body') }

  describe 'POST /comments' do
    context 'when user is not authenticated' do
      it 'redirects to the login page' do
        post comments_path, params: { comment: { body: 'New comment' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      it 'creates a comment with valid parameters and redirects to root_path' do
        expect {
          post comments_path, params: { comment: { body: 'New comment' } }
        }.to change(Comment, :count).by(1)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('comments.create.success'))
      end

      it 'does not create a comment with invalid parameters' do
        expect {
          post comments_path, params: { comment: { body: '' } }
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'PATCH/PUT /comments/:id' do
    context 'when user is not authenticated' do
      it 'redirects to the login page' do
        patch comment_path(comment_by_user), params: { comment: { body: 'Updated body' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      it 'updates the comment with valid parameters and redirects to root_path' do
        patch comment_path(comment_by_user), params: { comment: { body: 'Updated body' } }
        expect(comment_by_user.reload.body).to eq('Updated body')
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('comments.update.success'))
      end

      it 'does not update the comment with invalid parameters' do
        patch comment_path(comment_by_user), params: { comment: { body: '' } }
        expect(comment_by_user.reload.body).to eq('Original body')
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'DELETE /comments/:id' do
    context 'when user is not authenticated' do
      it 'redirects to the login page' do
        delete comment_path(comment_by_user)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is authenticated' do
      before { sign_in user }

      it 'destroys the comment and redirects to root_path' do
        expect {
          delete comment_path(comment_by_user)
        }.to change(Comment, :count).by(-1)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('comments.destroy.success'))
      end
    end
  end
end
