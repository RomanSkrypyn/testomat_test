# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def list
    @users = User.select('id', 'email', 'username')
    render json: @users
  end
end
