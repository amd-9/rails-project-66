# frozen_string_literal: true

require 'test_helper'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:developer)

    @repository = repositories(:ruby_repo)
  end

  test 'should get index' do
    get repositories_path
    assert_response :success
  end

  test 'should get new' do
    sign_in(@user)

    get new_repository_path
    assert_response :success
  end
end
