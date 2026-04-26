# frozen_string_literal: true

class RunRepoCheckJob
  include Sidekiq::Worker

  queue_as :default

  def perform(repo_id)
    repository = Repository.find(repo_id)
    repo_checker = ApplicationContainer.resolve(:repo_checker).new
    repo_checker.check(repository)
  end
end
