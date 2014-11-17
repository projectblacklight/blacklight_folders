module Blacklight::Folders
  module ApplicationHelper

    include CrudLinksHelper

    # The layout file from the main app might invoke
    # some of the named routes from blacklight, which
    # causes errors on the blacklight_folders views
    # unless you add the main_app prefix.
    def method_missing(method, *args)
      if main_app_url_helper?(method)
        main_app.send(method, *args)
      else
        super
      end
    end

    def search_action_url(*args)
      main_app.catalog_index_url *args
    end

  private

    def main_app_url_helper?(method)
      method.to_s.end_with?('_path', '_url') && main_app.respond_to?(method)
    end

  end
end
