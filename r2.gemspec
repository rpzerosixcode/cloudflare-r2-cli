# frozen_string_literal: true

require_relative "lib/r2/version"

Gem::Specification.new do |spec|
    spec.name        = "cloudflare-r2-cli"
    spec.version     = R2::VERSION
    spec.authors     = ["rpzerosixcode"]
    spec.summary     = "Ruby CLI to manage objects on Cloudflare R2."
    spec.description = "Command line tool in Ruby to manage objects on Cloudflare " \
                       "R2 directly from the terminal."
    spec.homepage    = "https://github.com/rpzerosixcode/cloudflare-r2-cli"
    spec.license     = "MIT"

    spec.required_ruby_version = Gem::Requirement.new(">= 3.3.0")

    spec.files = Dir.chdir(__dir__) do
        Dir["bin/**/*", "lib/**/*", "docs/**/*", "CHANGELOG.md", "LICENCE", "README.md", "Rakefile"]
    end

    spec.bindir        = "bin"
    spec.executables   = spec.files.grep(%r{\Abin/}) { |file| File.basename(file) }
    spec.require_paths = ["lib"]

    spec.add_dependency "aws-sdk-s3", "~> 1.229.0"
    spec.add_dependency "rexml", "~> 3.4.4"
    spec.add_dependency "thor", "~> 1.5.0"

    spec.add_development_dependency "rake", "~> 13.4"
    spec.add_development_dependency "rspec", "~> 3.13"
    spec.add_development_dependency "rubocop", "~> 1.90"
    spec.add_development_dependency "rubocop-rake", "~> 0.7"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
    spec.metadata["rubygems_mfa_required"] = "true"
end
