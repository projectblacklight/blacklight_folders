module Blacklight::Folders
  class Folder < ActiveRecord::Base
    belongs_to :user, polymorphic: true
    validates :user_id, presence: true
    validates :name, presence: true

    has_many :items, -> { order('position ASC') }, class_name: 'FolderItem', :dependent => :destroy
  end
end
