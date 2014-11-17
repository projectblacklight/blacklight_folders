module Blacklight::Folders
  module FoldersHelper

    def human_friendly_visibility(visibility)
      t("activerecord.attributes.blacklight/folders/folder.visibility.#{visibility}")
    end

  end
end
