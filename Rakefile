# frozen_string_literal: true

require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new

desc "Executa todos os testes"
RSpec::Core::RakeTask.new(:spec)

desc "Executa os testes E2E"
RSpec::Core::RakeTask.new(:e2e) do |task|
    task.pattern = "spec/e2e/**/*_spec.rb"
end

task default: :spec
