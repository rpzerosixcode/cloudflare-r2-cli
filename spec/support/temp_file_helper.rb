# frozen_string_literal: true

require "fileutils"
require "securerandom"

# Support for creating and removing temporary test files.
module TempFileHelper
    # Exclusive directory of the temporary files of the in-process tests.
    #
    # Isolated from the directory used by the E2E tests (`tmp/e2e`).
    TEST_TMP_DIR = File.expand_path("../../tmp/spec", __dir__).freeze

    # Creates a unique temporary file to be used in tests.
    #
    # The files are restricted to `tmp/spec/`, according to the project
    # guidelines, and are removed automatically after each example.
    #
    # @param prefix [String] prefix of the file name
    # @param content [String] content of the file
    # @return [String] path of the created file
    def create_temp_file(prefix: "test", content: "test content")
        FileUtils.mkdir_p(TEST_TMP_DIR)

        path = File.join(TEST_TMP_DIR, "#{prefix}-#{SecureRandom.hex(4)}.jpg")
        File.binwrite(path, content)

        path
    end

    # Removes the temporary files created during the tests.
    def cleanup_temp_files!
        FileUtils.rm_rf(TEST_TMP_DIR)
    end

    module_function :create_temp_file, :cleanup_temp_files!
end
