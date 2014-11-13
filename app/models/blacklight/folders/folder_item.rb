module Blacklight::Folders
  class FolderItem < ActiveRecord::Base
    belongs_to :folder
    acts_as_list scope: :folder
    validates :folder_id, presence: true

    belongs_to :document, polymorphic: true
    validates :document_id, presence: true

    before_save :apply_document_type#, :need_to_recount

    after_save :recount_folders

    def apply_document_type
      self.document_type ||= default_document_type.to_s
    end

    def default_document_type
      ::SolrDocument
    end

    def recount_folders
      Array(changes['folder_id']).compact.each do |folder_id|
        f = Folder.find(folder_id)
        f.recalculate_size
        f.save!
      end
    end

  end
end
