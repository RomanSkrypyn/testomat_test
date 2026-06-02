# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def read
    @notification = current_user.notifications.find(params.expect(:id))
    @notification.update(read: true)
    respond_to do |format|
      format.html { redirect_back_or_to(root_path) }
      format.json { render json: { success: true } }
    end
  end

  def read_all
    current_user.notifications.unread.update(read: true)
    respond_to do |format|
      format.html { redirect_back_or_to(root_path) }
      format.json { render json: { success: true } }
    end
  end
end
