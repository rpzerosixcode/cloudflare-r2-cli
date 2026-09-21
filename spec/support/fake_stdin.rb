# frozen_string_literal: true

# Support for controlling the standard input in tests.
#
# The confirmation prompts of the CLI are validated with a controlled input,
# so the suite never waits for a real user and the result does not depend on
# whether the test runner has a terminal attached.
module StdinHelper
    # Minimal standard input used to simulate the executions of the CLI.
    class FakeStdin
        # @param answers [Array<String, nil>] answers returned by each read
        # @param interactive [Boolean] whether the input simulates a terminal
        def initialize(*answers, interactive: true)
            @answers = answers
            @interactive = interactive
        end

        # Indicates whether the input is a terminal, as `$stdin` does.
        #
        # @return [Boolean] configured interactivity
        def tty?
            @interactive
        end

        # Returns the next answer of the simulated user.
        #
        # @return [String, nil] answer, or nil when the input is exhausted
        def gets
            @answers.shift
        end
    end

    # Replaces the standard input during the block, restoring it at the end.
    #
    # @param answers [Array<String, nil>] answers given by the simulated user
    # @param interactive [Boolean] whether the input simulates a terminal
    def with_fake_stdin(*answers, interactive: true)
        original = $stdin
        $stdin = FakeStdin.new(*answers, interactive: interactive)

        yield
    ensure
        $stdin = original
    end
end
