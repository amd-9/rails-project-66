# frozen_string_literal: true

class RepoCheckerStub
  def check(repository)
    check = repository.checks.build(commit_id: 'commit_sha')

    check.clone!
    check.run_check!
    check.complete_check!
  end
end
