# frozen_string_literal: true

class JsCheckStrategy
  def check(container, command_executor)
    command_executor.container_exec_command(container, ['mkdir', '/eslint-runner'])
    command_executor.container_exec_command(container, ['bash', '-c', 'cd /eslint-runner && npm install eslint@10.9.0 @eslint/js --save-dev'])
    command_executor.container_exec_command(container, ['bash', '-c', 'cd /eslint-runner && npx eslint -v'])
    command_executor.container_exec_command(container, ['cp', 'eslint.config.mjs', '/eslint-runner/eslint.config.mjs'])
    command_executor.container_exec_command(container, ['bash', '-c', 'NODE_OPTIONS="--no-warnings" /eslint-runner/node_modules/.bin/eslint -f json --config /eslint-runner/eslint.config.mjs --no-config-lookup .'])
  end
end
