# frozen_string_literal: true

Rails.application.configure do
  MissionControl::Jobs.http_basic_auth_user = ENV.fetch('MISSION_CONTROL_USER', nil)
  MissionControl::Jobs.http_basic_auth_password = ENV.fetch('MISSION_CONTROL_PASSWORD', nil)
end
