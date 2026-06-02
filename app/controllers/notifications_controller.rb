# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def read
    @notification = current_user.notifications.find(params[:id])
    @notification.update(read: true)
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      format.json { render json: { success: true } }
    end
  end

  def read_all
    current_user.notifications.unread.update_all(read: true)
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      format.json { render json: { success: true } }
    end
  end
end
