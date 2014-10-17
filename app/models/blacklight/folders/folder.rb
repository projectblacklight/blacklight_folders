module Blacklight::Folders
  class Folder < ActiveRecord::Base
    belongs_to :user, polymorphic: true
    validates :user_id, presence: true
  end
end
