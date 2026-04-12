# frozen_string_literal: true

require 'docker'

class RepoChecker
  attr_reader :container

  def check(repo_to_check)
    prepare_container
    clone_repo(repo_to_check)
    destroy_container
  end

  private

  def prepare_container
    @container = Docker::Container.create('cmd' => ['tail', '-f', '/dev/null'], 'Image' => 'ruby:3.2.11')
    @container.start
  end

  def destroy_container
    return if @container.nil?

    begin
      running_container = Docker::Container.get(@container.id)
    rescue Docker::Error::NotFoundError
      running_container = nil
    end

    return unless running_container

    @container.delete(force: true)
  end

  def clone_repo(repo_to_check)
    return unless @container.json['State']['Running']

    check = repo_to_check.checks.build({ status: :new })
    check.save!
    check.clone!
    @container.exec(['git', 'clone', repo_to_check.clone_url.to_s, 'app'])
    @container.exec(%w[gem install rubocop])
    check.run_check!
    @container.exec(['rubocop', '/app'])
    check = repo_to_check.checks.build({ status: :new })
    check.complete_check!
    check.passing = true
    check.save!

    # rescue
    #  debugger
    #  destroy_container
  end
end
