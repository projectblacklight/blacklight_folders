require 'acts_as_list'

module Blacklight::Folders
  class FolderItem < ActiveRecord::Base
    belongs_to :folder
    acts_as_list scope: :folder
    validates :folder_id, presence: true

    belongs_to :document, polymorphic: true
    validates :document_id, presence: true
  end
end
