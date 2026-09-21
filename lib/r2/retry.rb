# frozen_string_literal: true

module R2
    # Automatic retries with exponential backoff.
    #
    # Transient failures, such as brief network instabilities, are retried a
    # limited number of times. The wait between the attempts grows
    # exponentially and is capped, so the remote service has time to recover
    # without making the user wait indefinitely.
    #
    # Only the error classes informed as transient are retried; every other
    # failure is raised immediately, preserving the domain error mapping.
    module Retry
        # Total number of attempts: the first execution plus the retries.
        DEFAULT_MAX_ATTEMPTS = 3

        # Wait applied after the first failed attempt, in seconds.
        DEFAULT_BASE_DELAY = 0.5

        # Upper limit of the wait between attempts, in seconds.
        DEFAULT_MAX_DELAY = 5.0

        # Waiting strategy used when nothing else is provided.
        DEFAULT_SLEEPER = ->(seconds) { sleep(seconds) }

        # Description used in the diagnostics when the caller gives none.
        DEFAULT_DESCRIPTION = "operation"

        # Retry settings shared by the operations of a client.
        class Policy
            attr_reader :max_attempts, :base_delay, :max_delay

            # @param max_attempts [Integer] total number of attempts
            # @param base_delay [Float] wait after the first failure, in seconds
            # @param max_delay [Float] upper limit of the wait, in seconds
            def initialize(
                max_attempts: DEFAULT_MAX_ATTEMPTS,
                base_delay: DEFAULT_BASE_DELAY,
                max_delay: DEFAULT_MAX_DELAY
            )
                @max_attempts = max_attempts
                @base_delay = base_delay
                @max_delay = max_delay
            end

            # Wait applied after the given failed attempt.
            #
            # @param attempt [Integer] number of the attempt that just failed
            # @return [Float] seconds to wait before the next attempt
            def delay_for(attempt)
                [@base_delay * (2**(attempt - 1)), @max_delay].min
            end
        end

        # Runs the block, retrying the transient failures it raises.
        #
        # @param policy [Policy] retry settings
        # @param retry_on [Array<Class>] error classes considered transient
        # @param logger [#debug, nil] logger used for diagnostics
        # @param sleeper [#call, nil] waiting strategy used between attempts
        # @param description [String, nil] operation description used in the diagnostics
        # @yield the operation to run
        # @return [Object] result of the block
        # @raise [StandardError] error of the last attempt when the retries are exhausted
        def self.call(policy: Policy.new, retry_on: [], logger: nil, sleeper: nil, description: nil)
            attempt = 0
            description ||= DEFAULT_DESCRIPTION

            begin
                attempt += 1
                yield
            rescue StandardError => e
                raise unless transient?(e, retry_on) && attempt < policy.max_attempts

                delay = policy.delay_for(attempt)
                logger&.debug(retry_message(attempt, policy, description, e, delay))
                (sleeper || DEFAULT_SLEEPER).call(delay)
                retry
            end
        end

        # Indicates whether an error is considered transient.
        #
        # @param error [StandardError] error raised by the operation
        # @param retry_on [Array<Class>] error classes considered transient
        # @return [Boolean] true when the failure may be retried
        def self.transient?(error, retry_on)
            retry_on.any? { |error_class| error.is_a?(error_class) }
        end

        # Builds the diagnostic message of a retry.
        #
        # @param attempt [Integer] number of the attempt that just failed
        # @param policy [Policy] retry settings
        # @param description [String] description of the operation
        # @param error [StandardError] error raised by the attempt
        # @param delay [Float] seconds to wait before the next attempt
        # @return [String] message describing the retry
        def self.retry_message(attempt, policy, description, error, delay)
            "Retrying #{description} in #{delay}s (attempt #{attempt + 1} of " \
                "#{policy.max_attempts}) after a transient failure: " \
                "#{error.class}: #{error.message}"
        end
    end
end
