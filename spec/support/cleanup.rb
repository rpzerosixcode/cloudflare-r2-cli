# frozen_string_literal: true

# Automated cleanups of the test environment.
#
# Ensure that examples do not interfere with each other through leftovers
# from previous runs.
RSpec.configure do |config|
    # Removes leftovers from previous runs before starting the suite.
    config.before(:suite) do
        TempFileHelper.cleanup_temp_files!
    end

    # Removes the temporary files created during each example, regardless
    # of the example result.
    config.after(:each) do
        TempFileHelper.cleanup_temp_files!
    end
end
