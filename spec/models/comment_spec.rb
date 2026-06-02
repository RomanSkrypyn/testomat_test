# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:body) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  describe '#mentions' do
    it 'returns an array of unique usernames prefixed with @ in the body' do
      comment = build(:comment, body: 'Hello @alice and @bob, check this out @alice!')
      expect(comment.mentions).to contain_exactly('alice', 'bob,', 'alice!')
    end

    it 'returns empty array if no mentions' do
      comment = build(:comment, body: 'Just a regular comment.')
      expect(comment.mentions).to be_empty
    end
  end

  describe 'callbacks' do
    describe 'after_save :add_notification' do
      let!(:user) { create(:user, username: 'author') }
      let!(:mentioned_user1) { create(:user, username: 'alice') }
      let!(:mentioned_user2) { create(:user, username: 'bob') }

      it 'creates notifications for existing mentioned users' do
        comment = build(:comment, user: user, body: 'Hey @alice and @bob')
        expect { comment.save }.to change(Notification, :count).by(2)
        expect(Notification.pluck(:mentioned_user_id)).to contain_exactly(mentioned_user1.id, mentioned_user2.id)
      end

      it 'does not create notifications for non-existent users' do
        comment = build(:comment, user: user, body: 'Hey @nonexistent')
        expect { comment.save }.not_to change(Notification, :count)
      end

      it 'does not create a notification for the comment author (self-mention)' do
        comment = build(:comment, user: user, body: 'Hey @author and @alice')
        expect { comment.save }.to change(Notification, :count).by(1)
        expect(Notification.pluck(:mentioned_user_id)).to contain_exactly(mentioned_user1.id)
      end

      it 'does not create duplicate notifications' do
        comment = build(:comment, user: user, body: 'Hey @alice @alice')
        expect { comment.save }.to change(Notification, :count).by(1)
      end
    end
  end
end
