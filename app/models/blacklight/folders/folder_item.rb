require 'acts_as_list'

module Blacklight::Folders
  class FolderItem < ActiveRecord::Base
    belongs_to :folder
    acts_as_list scope: :folder
    validates :folder_id, presence: true

    belongs_to :document, polymorphic: true
    validates :document_id, presence: true

    before_save :apply_document_type

    def apply_document_type
      self.document_type ||= default_document_type.to_s
    end

    def default_document_type
      ::SolrDocument
    end

  end
end
