require "active_support/core_ext/module/aliasing"
require "active_support/logger"

module Xrc
  module MethodLoggable
    class << self
      attr_writer :logger

      def logger
        @logger ||= ActiveSupport::Logger.new(STDOUT)
      end
    end

    def log(method_name, &block)
      define_method("#{method_name}_with_log") do |*args|
        Xrc::MethodLoggable.logger.info(instance_exec(*args, &block))
        __send__("#{method_name}_without_log", *args)
      end
      alias_method_chain method_name, :log
    end
  end
end
