# frozen_string_literal: true

require "stringio"

# Capture of the standard and error outputs during test execution.
#
# The capture is restored even when the block raises an exception, such as
# the CLI termination via `SystemExit`.
module OutputCapture
    # Captures the standard output during the execution of the block.
    #
    # The captured content can be queried with `last_stdout`.
    def capture_stdout
        original = $stdout
        @captured_stdout = StringIO.new
        $stdout = @captured_stdout

        yield
    ensure
        $stdout = original
    end

    # Captures the error output during the execution of the block.
    #
    # The captured content can be queried with `last_stderr`.
    def capture_stderr
        original = $stderr
        @captured_stderr = StringIO.new
        $stderr = @captured_stderr

        yield
    ensure
        $stderr = original
    end

    # Returns the content of the last standard output capture.
    def last_stdout
        @captured_stdout.string
    end

    # Returns the content of the last error output capture.
    def last_stderr
        @captured_stderr.string
    end
end
