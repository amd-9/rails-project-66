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
    Docker::Image.create('fromImage' => 'ruby:3.2.11')
    @container = Docker::Container.create('WorkingDir' => '/app', 'cmd' => ['tail', '-f', '/dev/null'], 'Image' => 'ruby:3.2.11')
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

    begin
      check = repo_to_check.checks.build({ status: :new })
      check.save!
      check.clone_repo!
      @container.exec(['git', 'clone', repo_to_check.clone_url.to_s, '.'])
      repo_commit_id, = @container.exec(%w[git rev-parse HEAD])
      check.commit_id = repo_commit_id
      check.save!
      @container.exec(%w[gem install rubocop])
      @container.exec(%w[rubocop -v])
      check.run_check!
      check_result, = @container.exec(%w[rubocop])

      no_offences_re = 'no offenses detected'

      if no_offences_re.match?(check_result.to_s)
        check.passed = true
        check.complete_check!
      else
        check.fail_check!
      end
    ensure
      destroy_container
    end
  end
end
