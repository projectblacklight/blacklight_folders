module Blacklight::Folders
  module FoldersHelper

    def human_friendly_visibility(visibility)
      icon = visibility == Blacklight::Folders::Folder::PUBLIC ? 'unlock' : 'lock'
      safe_join([content_tag(:span, '', class:"glyphicon glyphicon-#{icon}"),
        t("activerecord.attributes.blacklight/folders/folder.visibility.#{visibility}")], ' ')
    end
  end
end
