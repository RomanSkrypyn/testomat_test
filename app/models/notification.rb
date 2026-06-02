# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :comment
  belongs_to :mentioned_user, class_name: 'User'

  validates :mentioned_user_id, uniqueness: { scope: :comment_id }

  scope :read, -> { where(read: true) }
  scope :unread, -> { where.not(read: true) }

  def unread?
    !read?
  end
end
