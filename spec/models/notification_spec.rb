# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'validations' do
    subject { create(:notification) }

    it { is_expected.to validate_uniqueness_of(:mentioned_user_id).scoped_to(:comment_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:comment) }
    it { is_expected.to belong_to(:mentioned_user).class_name('User') }
  end

  describe 'scopes' do
    let!(:read_notification) { create(:notification, read: true) }
    let!(:unread_notification) { create(:notification, read: false) }

    describe '.read' do
      it 'returns only read notifications' do
        expect(described_class.read).to contain_exactly(read_notification)
      end
    end

    describe '.unread' do
      it 'returns only unread notifications' do
        expect(described_class.unread).to contain_exactly(unread_notification)
      end
    end
  end

  describe '#unread?' do
    it 'returns true if the notification is unread' do
      notification = build(:notification, read: false)
      expect(notification.unread?).to be true
    end

    it 'returns false if the notification is read' do
      notification = build(:notification, read: true)
      expect(notification.unread?).to be false
    end
  end
end
