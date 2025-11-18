# frozen_string_literal: true

class Web::ApplicationController < ApplicationController
  helper_method :current_user

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end
end
