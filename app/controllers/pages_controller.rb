# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :comments, only: :home
  before_action :comment, only: :home
  def home
    @notifications = current_user ? current_user.notifications.includes(comment: :user).order(created_at: :desc) : []
  end

  private

  def comment
    @comment = current_user ? current_user.comments.build : Comment.new
  end

  def comments
    @comments = if params[:query].present?
                  Comment.search(params[:query], sort: ['updated_at:desc']).page(params[:page]).per(5)
                else
                  Comment.includes(:user).order(updated_at: :desc).page(params[:page]).per(5)
                end
  end
end
