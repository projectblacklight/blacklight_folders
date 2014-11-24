module Blacklight::Folders
  module Ability
    def initialize(user)
      super()
      folder_permissions(user)
    end

    def folder_permissions(user)
      can_manage_my_own_folders(user)
      can_read_public_folders(user)
      can :index, Blacklight::Folders::Folder, user_id: user.try(:id)
    end

    def can_manage_my_own_folders(user)
      return unless user
      can [:read, :update], Blacklight::Folders::Folder, user_id: user.id
      unless user.guest?
        can [:create, :destroy], Blacklight::Folders::Folder, user_id: user.id
      end

      can [:create, :destroy], Blacklight::Folders::FolderItem, folder: { user_id: user.id }
    end

    def can_read_public_folders(user)
      can :show, Blacklight::Folders::Folder, visibility: Blacklight::Folders::Folder::PUBLIC
    end

  end
end
