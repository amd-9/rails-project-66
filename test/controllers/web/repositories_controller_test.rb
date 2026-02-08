# frozen_string_literal: true

require 'test_helper'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:developer)

    @repository = repositories(:ruby_repo)
  end

  test 'should get index' do
    sign_in(@user)

    get repositories_path
    assert_response :success
  end

  test 'should get new' do
    sign_in(@user)

    stub_request(:any, "https://api.github.com/search/repositories?per_page=100&q=user:#{@user.nickname}%20language:ruby")
      .to_return_json(body: { total_count: 1, items: [{ name: 'test_repo', id: 1 }] })

    get new_repository_path
    assert_response :success
  end

  test 'should create repository' do
    sign_in(@user)

    repo_response = {
      name: 'test_repo',
      id: 1,
      full_name: 'Sapmle test repo',
      laguage: 'ruby',
      clone_url: 'https://github.com/test_repo/ruby_repo.git',
      ssh_url: 'git@github.com:test_repo/ruby_repo.git'
    }

    stub_request(:get, 'https://api.github.com/repositories/1')
      .to_return_json(body: repo_response)

    attrs = {
      github_id: 1
    }

    assert_difference('Repository.count') do
      post repositories_path, params: { repository: attrs }
    end
  end
end
