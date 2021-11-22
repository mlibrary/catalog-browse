# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "catalog-browse"
  spec.version       = "0.0.1"
  spec.authors       = [""]
  spec.email         = [""]

  spec.summary       = "Sinatra application for Catalog Browse"
  spec.description   = "Sinatra app for Catalog Browse"
  spec.homepage      = "https://github.com.mlibrary/catalog-browse"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{public/**/*,views/**/*,lib/**/*.rb,*.gemspec}')
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "sinatra"
  spec.add_dependency 'simple_solr_client'
  spec.add_dependency 'puma'
  spec.add_dependency 'slim'
  spec.add_dependency 'httparty'


  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
