# frozen_string_literal: true

require "base64"
require "fileutils"
require "open3"
require "rbconfig"
require "r2"
require "securerandom"

# E2E tests support.
#
# Loads the environment variables from the `.env` file and provides utilities
# to run the CLI in a separate process and prepare the test data.
#
# When the required credentials are not available, the scenarios are marked
# as pending, allowing the suite to run in environments without access to
# Cloudflare R2 (such as CI).
module E2EHelper
    ROOT = File.expand_path("../..", __dir__).freeze
    BIN = File.join(ROOT, "bin", "r2").freeze
    ENV_FILE = File.join(ROOT, ".env").freeze
    TEST_BUCKET = ENV.fetch("R2_TEST_BUCKET", "test-bucket").freeze

    # Minimal configuration used to clean up external objects.
    CLEANUP_CONFIG = Struct.new(
        :bucket,
        :region,
        :access_key_id,
        :secret_access_key,
        :endpoint
    )

    REQUIRED_VARS = %w[
        R2_ACCESS_KEY_ID
        R2_SECRET_ACCESS_KEY
        R2_ENDPOINT
    ].freeze

    # Minimal JPEG image (1x1) used as the content of the test files.
    JPEG_1X1 = Base64.decode64(
        "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8U" \
        "HRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA" \
        "/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEA" \
        "AD8AVN//2Q=="
    ).freeze

    # Loads the environment variables from the `.env` file, if it exists.
    #
    # Variables already defined in the environment take precedence and are
    # not overwritten.
    def load_test_env!
        return if @loaded

        @loaded = true
        return unless File.exist?(ENV_FILE)

        File.foreach(ENV_FILE) { |line| apply_env_line(line) }
    end

    # Runs the CLI in a separate process, as a user would in the terminal.
    #
    # The bucket used by the tests is always the test bucket.
    #
    # Loading via `-rbundler/setup` ensures that the project dependencies are
    # active, since the packaged binary does not depend on Bundler
    # (portability of the installed gem).
    def run_cli(*, env: {})
        load_test_env!
        ensure_required_env!

        Open3.capture3(
            process_env(env),
            RbConfig.ruby,
            "-rbundler/setup",
            BIN,
            *,
            chdir: ROOT
        )
    end

    # Creates a unique temporary file to be uploaded in the tests.
    def create_temp_file(prefix: "test")
        dir = File.join(ROOT, "tmp", "e2e")

        FileUtils.mkdir_p(dir)

        path = File.join(dir, "#{prefix}-#{SecureRandom.hex(4)}.jpg")
        File.binwrite(path, JPEG_1X1)

        tracked_files << path

        path
    end

    # Removes the temporary files created during the tests.
    def cleanup_temp_files!
        FileUtils.rm_rf(File.join(ROOT, "tmp", "e2e"))
    end

    # Removes from the test bucket the objects uploaded during the tests.
    #
    # Considers that each file created by `create_temp_file` is uploaded by
    # the `upload` command, using the file name as the object key in the bucket.
    #
    # The cleanup is failure tolerant: network or credential errors only log
    # a warning, avoiding the cleanup marking an already validated scenario
    # as failed.
    def cleanup_external_data!
        keys = tracked_files.map { |path| File.basename(path) }.uniq
        return if keys.empty? || missing_required_env?

        keys.each { |key| external_storage.delete(key: key) }
    rescue StandardError => e
        warn "Warning: could not clean up the external objects in the test bucket: #{e.message}"
    ensure
        tracked_files.clear
    end

    # Paths of the files created during the tests not yet cleaned up.
    def tracked_files
        @tracked_files ||= []
    end

    # Storage used to clean up the external objects.
    #
    # Always directed to the test bucket, isolated from the production
    # environment.
    def external_storage
        config = CLEANUP_CONFIG.new(
            TEST_BUCKET,
            ENV.fetch("R2_REGION", "auto"),
            ENV.fetch("R2_ACCESS_KEY_ID"),
            ENV.fetch("R2_SECRET_ACCESS_KEY"),
            ENV.fetch("R2_ENDPOINT")
        )

        R2::Storage.new(config)
    end

    # Applies a line of the `.env` file to the environment, when valid.
    def apply_env_line(line)
        key, value = line.strip.split("=", 2)

        return if key.nil? || value.nil? || key.empty? || key.start_with?("#")

        ENV[key] = value unless ENV.key?(key)
    end

    # Ensures that the required environment variables are available, marking
    # the scenario as pending when they are not.
    def ensure_required_env!
        missing = REQUIRED_VARS.reject { |variable| ENV.key?(variable) }

        return if missing.empty?

        skip "Required environment variables are missing: #{missing.join(", ")}. " \
             "Define them in the .env file or in the environment."
    end

    private

    # Builds the CLI execution environment, always directed to the test bucket.
    def process_env(env)
        {
            "R2_ACCESS_KEY_ID" => ENV.fetch("R2_ACCESS_KEY_ID"),
            "R2_SECRET_ACCESS_KEY" => ENV.fetch("R2_SECRET_ACCESS_KEY"),
            "R2_ENDPOINT" => ENV.fetch("R2_ENDPOINT"),
            "R2_REGION" => ENV.fetch("R2_REGION", "auto"),
            "R2_BUCKET" => TEST_BUCKET
        }.merge(env)
    end

    # Indicates whether any required environment variable is missing.
    def missing_required_env?
        REQUIRED_VARS.any? { |variable| !ENV.key?(variable) }
    end

    module_function :load_test_env!,
                    :run_cli,
                    :create_temp_file,
                    :cleanup_temp_files!,
                    :apply_env_line,
                    :ensure_required_env!
end
