# frozen_string_literal: true

class JSCheckStrategy
  def check(container, command_executor)
    command_executor.container_exec_command(container, %w[npm install --save-dev eslint @eslint/js])
    command_executor.container_exec_command(container, %w[npx eslint -v])
    command_executor.container_exec_command(container, %w[npx eslint -f json --config eslint.config.mjs --no-config-lookup .])
  end
end
