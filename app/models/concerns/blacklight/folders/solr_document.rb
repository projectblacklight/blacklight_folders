module Blacklight::Folders::SolrDocument
  extend ActiveSupport::Concern


  # Returns the user's folders, partitioned into 2 arrays:
  # 1. Folders that contain this SolrDocument
  # 2. Folders that don't contain this SolrDocument
  def folders_for_user(user)
    folders_without_doc = Blacklight::Folders::Folder.without_doc_for_user(self, user)
    folders_with_doc = user.folders - folders_without_doc
    [folders_with_doc, folders_without_doc]
  end

end
