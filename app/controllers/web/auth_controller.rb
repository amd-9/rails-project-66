# frozen_string_literal: true

class Web::AuthController < Web::ApplicationController
  def callback
    user_info = request.env['omniauth.auth']
    user_nickname = user_info[:info][:nickname]
    user_email = user_info[:info][:email]
    user_token = user_info[:credentials][:token]

    user = User.find_or_initialize_by(email: user_email)
    user.nickname = user_nickname
    user.token = user_token

    flash_message = user.persisted? ? t('auth.welcome_back') : t('auth.login.success')

    if user.save
      flash[:info] = flash_message
      session[:user_id] = user.id
    else
      flash[:alert] = t('auth.login.error')
    end
    redirect_to root_path
  end

  def logout
    reset_session
    redirect_to root_path, notice: t('auth.logout.success')
  end

  def auth_params
    params.require(:user_info)
  end
end
