module Blacklight::Folders
  module FoldersHelper

    def human_friendly_visibility(visibility)
      icon = visibility == Blacklight::Folders::Folder::PUBLIC ? 'unlock' : 'lock'
      safe_join([content_tag(:span, '', class:"glyphicon glyphicon-#{icon}"),
        t("activerecord.attributes.blacklight/folders/folder.visibility.#{visibility}")], ' ')
    end

    def folder_export_url(folder, format)
      polymorphic_path([blacklight_folders, folder], format: format, only_path: false, encrypted_user_id: encrypt_user_id(current_or_guest_user.id))
    end
  end
end
