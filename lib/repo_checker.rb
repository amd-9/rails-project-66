# frozen_string_literal: true

require 'docker_engine_ruby'

class RepoChecker
  attr_reader :container, :docker, :images_by_language, :check

  def initialize
    @images_by_language = {
      'Ruby' => 'ruby:4.0.6',
      'nodejs' => 'node:20.5.1'
    }

    @docker = DockerEngineRuby::Client.new(
      base_url: ENV.fetch('DOCKER_API_BASE_URL', nil)
    )
  end

  def run(repo_to_check)
    @check = repo_to_check.checks.build({ status: :new })
    @check.save!

    prepare_container(repo_to_check.id, repo_to_check.language)
    clone_repo(repo_to_check)
    upload_check_profile
    check_repo(repo_to_check.language)
  rescue StandardError => e
    check.log = e.full_message
    check.fail_check!
  ensure
    destroy_container
  end

  # private

  def prepare_container(id, language)
    image = images_by_language[language]

    prepare_image(image)

    @container = @docker.containers.create(
      name: "check_#{id}",
      config: {
        Image: image,
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

  def prepare_image(image_to_prepare)
    @docker.images.inspect_(image_to_prepare)
  rescue DockerEngineRuby::Errors::NotFoundError
    @docker.images.pull(from_image: image_to_prepare)
  end

  def destroy_container
    return if @container.nil?

    @docker.containers.delete(@container.id, force: true)
  end

  def clone_repo(repo_to_check)
    check.clone_repo!
    conatiner_exec_command(['git', 'clone', repo_to_check.clone_url.to_s, '.'])
    check.commit_id = conatiner_exec_command(%w[git rev-parse HEAD])
    check.save!
  end

  def check_repo(_language)
    conatiner_exec_command(%w[gem install rubocop rubocop-rails])
    conatiner_exec_command(%w[rubocop -v])
    check.run_check!
    check_result = conatiner_exec_command(%w[rubocop --format json])
    check.log = check_result

    if check_result.to_s.match?(/no offenses detected/)
      check.passed = true
      check.complete_check!
    else
      check.fail_check!
    end
  end

  def upload_check_profile
    file_bytes = File.binread('rubocop.tar.gz')

    @docker.request(
      method: :put,
      path: "containers/#{@container.id}/archive",
      query: { path: '/app' },
      headers: { 'Content-Type' => 'application/x-tar' },
      body: file_bytes
    )
  end

  def conatiner_exec_command(command)
    exec_command = @docker.containers.exec_(
      @container.id,
      cmd: command,
      attach_stdout: true,
      attach_stderr: true,
      tty: true
    )

    command_raw_response = @docker.request(
      method: :post,
      path: "/exec/#{exec_command.id}/start",
      body: {
        Detach: false,
        Tty: true
      }
    )

    command_raw_response.string
  end
end
