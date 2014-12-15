# This helper is included by the main app, so that Blacklight Catalog pages can use these functions.
module Blacklight::Folders::MainAppHelper
  # Give a list of folder options for a select drop down
  # @param [Hash] options
  # @option options [SolrDocument] :without only show folders that don't include this document
  def options_for_folder_select(options={})
    collection = if current_or_guest_user.guest?
      current_or_guest_user.folders
    else
      folders = Blacklight::Folders::Folder.for_user(current_or_guest_user)
      folders = folders.without_document(options[:without]) if options.key?(:without)
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
