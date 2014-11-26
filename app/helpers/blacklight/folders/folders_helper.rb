module Blacklight::Folders
  module FoldersHelper

    def human_friendly_visibility(visibility)
      icon = visibility == Blacklight::Folders::Folder::PUBLIC ? 'unlock' : 'lock'
      safe_join([content_tag(:span, '', class:"glyphicon glyphicon-#{icon}"),
        t("activerecord.attributes.blacklight/folders/folder.visibility.#{visibility}")], ' ')
    end

    def folders_selection_for_doc(doc, user)
      folders = Blacklight::Folders::Folder.without_doc_for_user(doc, user).order(:name)
      default = user.default_folder
      sort_folders_with_default_first(folders, default)
    end

  end
end
