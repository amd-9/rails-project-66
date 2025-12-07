# frozen_string_literal: true

class Web::RepositoriesController < Web::ApplicationController
  require 'octokit'

  before_action :authorize_user

  def index
    @repos = []

    return if current_user.nil?

    @repos = Repository.where(user: current_user)
  end

  def new
    @repos = []
    @repository = Repository.new

    return if current_user.nil?

    client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
    @repos = client.repos.presence || []
  end

  def create
    client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
    selected_repository = client.repository(params[:repository][:github_id].to_i)

    repository = Repository.new
    repository.name = selected_repository[:name]
    repository.github_id = selected_repository[:id]
    repository.full_name = selected_repository[:full_name]
    repository.language = selected_repository[:laguage]
    repository.clone_url = selected_repository[:clone_url]
    repository.ssh_url = selected_repository[:ssh_url]
    repository.user = current_user

    if repository.save
      redirect_to root_path, notice: t('repository.create.success')
    else
      render :new, status: :unprocessable_content
    end
  end

  def authorize_user
    return redirect_to root_path, alert: t('auth.not_logged_in') while current_user.nil?
  end
end
