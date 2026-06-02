# frozen_string_literal: true

class User < ApplicationRecord
  include Users::Registerable

  has_many :comments, dependent: :destroy
  has_many :notifications, foreign_key: :mentioned_user_id, inverse_of: :mentioned_user, dependent: :destroy

  validates :username, presence: true, uniqueness: true

  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end
end
