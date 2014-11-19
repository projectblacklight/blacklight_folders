module Blacklight::Folders::User
  extend ActiveSupport::Concern

  included do
    has_many :folders, class_name: 'Blacklight::Folders::Folder', as: :user
    after_create :create_default_folder
  end

  def create_default_folder
    folders.create(name: I18n.translate(:'blacklight_folders.default_folder_name'))
  end

end
