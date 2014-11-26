# This helper is included by the main app, so that Blacklight Catalog pages can use these functions.
module Blacklight::Folders::MainAppHelper
  def options_for_folder_select
    collection = if current_or_guest_user.guest?
      current_or_guest_user.folders
    else
      folders = Blacklight::Folders::Folder.accessible_by(current_ability, :update).order(:name)
      sort_folders_with_default_first(folders, current_or_guest_user.default_folder)
    end

    options_from_collection_for_select(collection, :id, :name)
  end

  def sort_folders_with_default_first(folders, default)
    if default
      [default] + (folders - [default])
    else
      folders
    end
  end

end
