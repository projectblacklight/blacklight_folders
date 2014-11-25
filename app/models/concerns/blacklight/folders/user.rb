module Blacklight::Folders::User
  extend ActiveSupport::Concern

  included do
    has_many :folders, class_name: 'Blacklight::Folders::Folder', as: :user, inverse_of: :user
    after_create :create_default_folder
  end

  def create_default_folder
    folders.create(name: Blacklight::Folders::Folder.default_folder_name) unless guest?
  end

  def default_folder
    folders.where(name: Blacklight::Folders::Folder.default_folder_name).first
  end
end
