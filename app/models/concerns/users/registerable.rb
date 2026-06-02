# frozen_string_literal: true

module Users
  module Registerable
    extend ActiveSupport::Concern

    included do
      devise :database_authenticatable, :registerable, :recoverable,
             :rememberable, :trackable, :validatable, :confirmable
    end
  end
end
