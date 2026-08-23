# frozen_string_literal: true

class ExecCommand
  attr_reader :docker

  def initialize(docker)
    @docker = docker
  end

  def container_exec_command(container, command)
    exec_command = @docker.containers.exec_(
      container.id,
      cmd: command,
      attach_stdout: true,
      attach_stderr: true,
      tty: true
    )

    command_raw_response = docker.request(
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
