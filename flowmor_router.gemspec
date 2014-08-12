$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "flowmor_router/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "flowmor_router"
  s.version     = FlowmorRouter::VERSION
  s.authors     = ["Michael Lang"]
  s.email       = ["mwlang@cybrains.net"]
  s.homepage    = "http://codeconnoisseur.org"
  s.summary     = "FlowmorRouter makes it easy to build routes out of ActiveRecord objects."
  s.description = "FlowmorRouter allows you to create 'friendly' routes easily from objects stored in the database as well as by simply placing templates into app/views/static folder."
  s.license     = "MIT"

  s.files = Dir["{app,bin,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4"

  s.add_development_dependency "sqlite3", "~> 1.3"
end
