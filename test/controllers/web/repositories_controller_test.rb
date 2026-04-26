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

    get new_repository_path
    assert_response :success
  end

  test 'should create repository' do
    sign_in(@user)

    attrs = {
      github_id: 1
    }

    assert_difference('Repository.count') do
      post repositories_path, params: { repository: attrs }
    end
  end

  test 'should run repository check' do
    sign_in(@user)

    Sidekiq::Testing.inline! do
      assert_difference('Repository::Check.count') do
        patch run_check_repository_path(@repository)
      end
    end

    last_check = Repository::Check.last

    assert last_check.completed?
  end
end
