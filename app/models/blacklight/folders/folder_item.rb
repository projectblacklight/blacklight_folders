require 'acts_as_list'

module Blacklight::Folders
  class FolderItem < ActiveRecord::Base
    self.table_name = 'blacklight_folders_bookmarks_folders'
    belongs_to :folder
    validates :folder_id, presence: true
    acts_as_list scope: :folder

    belongs_to :bookmark, dependent: :destroy
    validates :bookmark_id, presence: true
  end
end
