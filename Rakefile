# frozen_string_literal: true

require "fileutils"
require "rubocop/rake_task"
require "rspec/core/rake_task"
require_relative "lib/r2/version"

RuboCop::RakeTask.new

desc "Executa todos os testes"
RSpec::Core::RakeTask.new(:spec)

desc "Executa os testes unitários"
RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = "spec/unit/**/*_spec.rb"
end

desc "Executa os testes de integração"
RSpec::Core::RakeTask.new(:integration) do |task|
    task.pattern = "spec/integration/**/*_spec.rb"
end

desc "Executa os testes E2E"
RSpec::Core::RakeTask.new(:e2e) do |task|
    task.pattern = "spec/e2e/**/*_spec.rb"
end

desc "Constrói a gem em pkg/"
task :build do
    FileUtils.mkdir_p("pkg")
    gem_file = "pkg/cloudflare-r2-cli-#{R2::VERSION}.gem"
    sh "gem build r2.gemspec --output #{gem_file}"
end

desc "Instala a gem localmente"
task install: :build do
    gem_file = "pkg/cloudflare-r2-cli-#{R2::VERSION}.gem"
    sh "gem install #{gem_file} --no-document"
end

desc "Executa as verificações do CI (estilo, testes e empacotamento)"
task ci: %i[rubocop spec build]

task default: :spec
