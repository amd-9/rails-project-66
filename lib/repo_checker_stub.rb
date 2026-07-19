# frozen_string_literal: true

class RepoCheckerStub
  def run(repository)
    check = repository.checks.build(commit_id: 'commit_sha')

    check.clone_repo!
    check.run_check!
    check.complete_check!
  end
end
