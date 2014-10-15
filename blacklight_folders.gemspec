$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "blacklight_folders/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "blacklight_folders"
  s.version     = BlacklightFolders::VERSION
  s.authors     = ["Data Curation Experts"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of BlacklightFolders."
  s.description = "TODO: Description of BlacklightFolders."
  s.license     = "See LICENSE file"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0", ">= 4.0.1"

  s.add_development_dependency "sqlite3"
end
