require 'acts_as_list'

module Blacklight::Folders
  class FolderItem < ActiveRecord::Base
    after_save :recount_folders
    belongs_to :folder, touch: true
    validates :folder_id, presence: true
    acts_as_list scope: :folder

    belongs_to :bookmark, dependent: :destroy
    validates :bookmark_id, presence: true

    def recount_folders
      Array(changes['folder_id']).compact.each do |folder_id|
        f = Folder.find(folder_id)
        f.recalculate_size
        f.save!
      end
    end
  end
end
