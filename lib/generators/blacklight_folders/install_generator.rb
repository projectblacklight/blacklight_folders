module BlacklightFolders
  class InstallGenerator < Rails::Generators::Base

    desc "It will set up your rails app to use the blacklight_folders engine.\n\n"

    def add_routes
      route 'mount Blacklight::Folders::Engine, at: "blacklight"'
    end

    def run_migrations
      rake "blacklight_folders:install:migrations"
      rake "db:migrate"
    end

    def add_model_mixins
      inject_into_class 'app/models/user.rb', User, '  include Blacklight::Folders::User'
      inject_into_class 'app/models/solr_document.rb', SolrDocument, '  include Blacklight::Folders::SolrDocument'
    end

    def add_controller_mixins
      inject_into_file 'app/controllers/application_controller.rb', :after => /Blacklight::Controller\s*\n/ do
        "  include Blacklight::Folders::ApplicationControllerBehavior\n"
      end
    end

    def add_style
      inject_into_file 'app/assets/stylesheets/blacklight.css.scss', "@import 'blacklight_folders/blacklight_folders';", after: /@import 'blacklight\/blacklight';\s*\n/
    end

  end
end
