# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :github_client, -> { OctokitClientStub }
    register :repo_checker, -> { RepoCheckerStub }
  else
    register :github_client, -> { Octokit::Client }
    register :repo_checker, -> { RepoChecker }
  end
end
