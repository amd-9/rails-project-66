# frozen_string_literal: true

class RubyCheckStrategy
  def check(container, command_executor)
    command_executor.container_exec_command(container, %w[gem install rubocop rubocop-rails])
    command_executor.container_exec_command(container, %w[rubocop -v])
    command_executor.container_exec_command(container, %w[rubocop --format json])
  end
end
