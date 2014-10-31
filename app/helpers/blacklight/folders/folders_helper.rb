module Blacklight::Folders
  module FoldersHelper

    def blacklight_config
      ::CatalogController.blacklight_config
    end

  end
end
