require 'acts_as_list'

module Blacklight::Folders
  class BookmarksFolder < ActiveRecord::Base
    belongs_to :folder
    validates :folder_id, presence: true
    acts_as_list scope: :folder

    belongs_to :bookmark, dependent: :destroy
    validates :bookmark_id, presence: true
  end
end
