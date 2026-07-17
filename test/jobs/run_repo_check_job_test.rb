# frozen_string_literal: true

require 'test_helper'

class RunRepoCheckJobTest < ActiveJob::TestCase

  setup do
    @repository = repositories(:ruby_repo)
  end

  test 'should run repo check' do
    assert_enqueued_with(job: RunRepoCheckJob) do
      RunRepoCheckJob.perfom_later(@repository.id)
    end

    last_check = Repository::Check.last

    assert last_check.completed?
  end
end
