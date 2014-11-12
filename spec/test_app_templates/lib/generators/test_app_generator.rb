require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "./spec/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application

  def add_gems
    gem "blacklight", ">=5.4.0"
    Bundler.with_clean_env { run "bundle install" }
  end

  def run_blacklight_generator
    generate "blacklight:install", "--devise"
  end

  def run_blacklight_folders_generator
    generate 'blacklight_folders:install'
  end

  def config_solr
    src_dir = File.expand_path('../../../../../spec/test_app_templates', __FILE__)
    remove_file 'config/solr.yml'
    copy_file File.join(src_dir, 'solr.yml'), 'config/solr.yml'
  end

end
