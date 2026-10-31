require "xrc"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end

Xrc::MethodLoggable.logger.level = 2
