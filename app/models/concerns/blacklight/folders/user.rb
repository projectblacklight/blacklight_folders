module Blacklight::Folders::User
  extend ActiveSupport::Concern

  included do
    has_many :folders, class_name: 'Blacklight::Folders::Folder'
  end

end
