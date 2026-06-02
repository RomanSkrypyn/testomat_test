# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:email) }

    describe 'uniqueness' do
      before { create(:user, username: 'testuser', email: 'test@example.com') }

      it 'validates uniqueness of username' do
        duplicate_user = build(:user, username: 'testuser', email: 'other@example.com')
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:username]).to include('has already been taken')
      end

      it 'validates uniqueness of email case-insensitively' do
        duplicate_user = build(:user, username: 'otheruser', email: 'TEST@example.com')
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to include('has already been taken')
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).with_foreign_key(:mentioned_user_id).inverse_of(:mentioned_user).dependent(:destroy) }
  end
end
