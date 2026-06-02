# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :comment, only: %i[update destroy]

  def create
    @comment = current_user.comments.build(comment_params)

    if @comment.save
      redirect_to root_path, notice: t('.success')
    else
      redirect_to root_path, alert: @comment.errors.full_messages.join(', ')
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to root_path, notice: t('.success')
    else
      redirect_to root_path, alert: @comment.errors.full_messages.join(', ')
    end
  end

  def destroy
    @comment.destroy

    redirect_to root_path, notice: t('.success')
  end

  private

  def comment
    @comment = Comment.find(params.expect(:id))
  end

  def comment_params
    params.expect(comment: [:body])
  end
end
