# frozen_string_literal: true

require "logger"

module R2
    # Builds and configures loggers used for diagnostics.
    module Logging
        # Discards all diagnostic messages.
        #
        # Used as the default when no logger is provided, keeping
        # collaborators free from nil checks.
        class NullLogger
            # Ignores a debug message.
            #
            # @param _message [String] message to ignore
            # @return [nil]
            def debug(_message); end
        end

        # Builds a logger according to the requested verbosity.
        #
        # @param verbose [Boolean] whether detailed output is enabled
        # @param output [IO] destination of the diagnostic messages
        # @return [Logger, NullLogger] configured logger
        def self.build(verbose: false, output: $stderr)
            return NullLogger.new unless verbose

            Logger.new(output).tap do |log|
                log.level = Logger::DEBUG
                log.formatter = proc { |_severity, _datetime, _progname, message| "#{message}\n" }
            end
        end
    end
end
