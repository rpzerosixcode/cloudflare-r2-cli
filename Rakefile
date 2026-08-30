# frozen_string_literal: true

require "fileutils"
require "rubocop/rake_task"
require "rspec/core/rake_task"
require_relative "lib/r2/version"

RuboCop::RakeTask.new

desc "Runs all tests"
RSpec::Core::RakeTask.new(:spec)

desc "Runs the unit tests"
RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = "spec/unit/**/*_spec.rb"
end

desc "Runs the integration tests"
RSpec::Core::RakeTask.new(:integration) do |task|
    task.pattern = "spec/integration/**/*_spec.rb"
end

desc "Runs the E2E tests"
RSpec::Core::RakeTask.new(:e2e) do |task|
    task.pattern = "spec/e2e/**/*_spec.rb"
end

desc "Builds the gem into pkg/"
task :build do
    FileUtils.mkdir_p("pkg")
    gem_file = "pkg/cloudflare-r2-cli-#{R2::VERSION}.gem"
    sh "gem build r2.gemspec --output #{gem_file}"
end

desc "Installs the gem locally"
task install: :build do
    gem_file = "pkg/cloudflare-r2-cli-#{R2::VERSION}.gem"
    sh "gem install #{gem_file} --no-document"
end

desc "Runs the CI checks (style, tests and packaging)"
task ci: %i[rubocop spec build]

task default: :spec
