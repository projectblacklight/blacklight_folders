$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "blacklight_folders/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "blacklight_folders"
  s.version     = Blacklight::Folders::VERSION
  s.authors     = ["Data Curation Experts"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Blacklight::Folders."
  s.description = "TODO: Description of Blacklight::Folders."
  s.license     = "See LICENSE file"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0", ">= 4.0.1"
  s.add_dependency "acts_as_list", ">= 0.4.0"
  s.add_dependency "blacklight", ">= 5.7.1", "<6"
  s.add_dependency "cancancan", "~> 1.9"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "jettywrapper"
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "engine_cart", "~> 0.4.0"
end
