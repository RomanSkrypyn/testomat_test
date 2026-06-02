# frozen_string_literal: true

class Comment < ApplicationRecord
  include Comments::Meilisearchable

  belongs_to :user
  has_many :notifications, dependent: :destroy

  validates :body, presence: true

  after_save :add_notification

  def mentions
    body.scan(/@(\S+)/).flatten.uniq
  end

  private

  def add_notification
    mentions.each do |username|
      mentioned_user = User.find_by(username: username)
      next if mentioned_user.blank?
      # TODO Remove comment below
      # next if mentioned_user.id == user_id

      notifications.create(mentioned_user: mentioned_user)
    end
  end
end
