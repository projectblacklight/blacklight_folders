require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "./spec/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application

  # def install_engine
  #   generate 'blacklight_folders:install'
  # end

  def add_routes
    route 'mount Blacklight::Folders::Engine, at: "blacklight"'
  end

  def add_gems
    gem "blacklight", ">=5.4.0"
    Bundler.with_clean_env { run "bundle install" }
  end

  def run_blacklight_generator
    generate "blacklight:install", "--devise"
  end

  def run_migrations
    rake "blacklight_folders:install:migrations"
    rake "db:migrate"
  end

end
