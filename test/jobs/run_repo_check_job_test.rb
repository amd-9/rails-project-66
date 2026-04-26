# frozen_string_literal: true

require 'test_helper'

class RunRepoCheckJobTest < ActiveJob::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @repository = repositories(:ruby_repo)
  end

  test 'should run repo check' do
    Sidekiq::Testing.inline! do
      assert_difference('Repository::Check.count') do
        RunRepoCheckJob.perform_async(@repository.id)
      end

      last_check = Repository::Check.last

      assert last_check.completed?
    end
  end
end
