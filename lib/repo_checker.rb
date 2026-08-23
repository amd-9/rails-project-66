# frozen_string_literal: true

require 'docker_engine_ruby'
require_relative 'docker/exec_command'
require_relative 'check_strategies/ruby_check_strategy'
require_relative 'check_strategies/js_check_strategy'

class RepoChecker
  attr_reader :container, :docker, :images_by_language, :check_profiles_by_language, :check, :command_executor
  attr_accessor :repo_to_check

  def initialize
    @images_by_language = {
      'Ruby' => 'ruby:4.0.6',
      'JavaScript' => 'node:24.19.0'
    }

    @check_profiles_by_language = {
      'Ruby' => 'rubocop.tar.gz',
      'JavaScript' => 'eslint.config.tar.gz'
    }

    @check_strategies_by_language = {
      'Ruby' => RubyCheckStrategy,
      'JavaScript' => JSCheckStrategy
    }

    @docker = DockerEngineRuby::Client.new(
      base_url: ENV.fetch('DOCKER_API_BASE_URL', nil)
    )

    @command_executor = ExecCommand.new(@docker)
  end

  def run(repo_to_check)
    @repo_to_check = repo_to_check
    @check = repo_to_check.checks.build({ status: :new })
    @check.save!

    prepare_container
    clone_repo
    upload_check_profile
    check_repo
  rescue StandardError => e
    @check.log = e.full_message
    @check.fail_check! unless check.failed?
  ensure
    destroy_container
    @check.save!
  end

  # private

  def prepare_container
    prepare_image

    @container = @docker.containers.create(
      name: "check_#{@check.id}",
      config: {
        Image: images_by_language[@repo_to_check.language],
        WorkingDir: '/app',
        Cmd: ['tail', '-f', '/dev/null'],
        HostConfig: {
          Memory: 1024 * 1024 * 1024,
          NanoCpus: 1_000_000_000
        }
      }
    )

    @docker.containers.start(@container.id)
  end

  def prepare_image
    @docker.images.inspect_(images_by_language[@repo_to_check.language])
  rescue DockerEngineRuby::Errors::NotFoundError
    @docker.images.pull(from_image: images_by_language[@repo_to_check.language])
  end

  def destroy_container
    return if @container.nil?

    @docker.containers.delete(@container.id, force: true)
  end

  def clone_repo
    check.clone_repo!
    @command_executor.container_exec_command(@container, ['git', 'clone', @repo_to_check.clone_url.to_s, '.'])
    check.commit_id = @command_executor.container_exec_command(@container, %w[git rev-parse HEAD])
    check.save!
  end

  def check_repo
    check_strategy = @check_strategies_by_language[@repo_to_check.language].new

    check.run_check!
    check.log = check_strategy.check(@container, command_executor)

    if check.log.to_s.match?(/no offenses detected/)
      check.passed = true
      check.complete_check!
    else
      check.fail_check!
    end
  end

  def upload_check_profile
    file_bytes = File.binread(check_profiles_by_language[@repo_to_check.language])

    @docker.request(
      method: :put,
      path: "containers/#{@container.id}/archive",
      query: { path: '/app' },
      headers: { 'Content-Type' => 'application/x-tar' },
      body: file_bytes
    )
  end
end
