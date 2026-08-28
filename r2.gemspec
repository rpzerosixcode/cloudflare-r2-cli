# frozen_string_literal: true

require_relative "lib/r2/version"

Gem::Specification.new do |spec|
    spec.name                  = "r2"
    spec.version               = R2::VERSION
    spec.authors               = ["rpzerosixcode"]
    spec.summary               = "CLI em Ruby para gerenciar objetos no Cloudflare R2."
    spec.description           = "Ferramenta de linha de comando em Ruby para gerenciar " \
                                 "objetos no Cloudflare R2 diretamente pelo terminal."
    spec.license               = "MIT"
    spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

    spec.files = Dir.chdir(__dir__) do
        Dir["bin/**/*", "lib/**/*", "docs/**/*", "LICENCE", "README.md", "Rakefile"]
    end
    spec.bindir        = "bin"
    spec.executables   = spec.files.grep(%r{\Abin/}) { |file| File.basename(file) }
    spec.require_paths = ["lib"]

    spec.add_dependency "aws-sdk-s3", ">= 1.0.0"
    spec.add_dependency "rexml", ">= 3.0"
    spec.add_dependency "thor", ">= 1.0.0"

    spec.add_development_dependency "rake", "~> 13.0"
    spec.add_development_dependency "rubocop", "~> 1.0"
    spec.add_development_dependency "rubocop-rake", "~> 0.7"
    spec.metadata["rubygems_mfa_required"] = "true"
end
