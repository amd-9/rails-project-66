# frozen_string_literal: true

require 'test_helper'

class RunRepoCheckJobTest < ActiveJob::TestCase
  setup do
    @repository = repositories(:ruby_repo)
  end

  test 'should run repo check' do
    assert_enqueued_with(job: RunRepoCheckJob) do
      RunRepoCheckJob.perform_later(@repository.id)
    end

    perform_enqueued_jobs

    last_check = Repository::Check.last

    assert last_check.completed?
  end
end
