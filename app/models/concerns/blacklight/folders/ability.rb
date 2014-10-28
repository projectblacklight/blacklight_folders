module Blacklight::Folders
  module Ability
    extend ActiveSupport::Concern

    def folder_permissions(user)
      can_manage_my_own_private_folders(user)
      can_read_public_folders(user)
    end

    def can_manage_my_own_private_folders(user)
      return unless user
      can :manage, Blacklight::Folders::Folder, user_id: user.id
    end

    def can_read_public_folders(user)
      can :read, Blacklight::Folders::Folder, visibility: Blacklight::Folders::Folder::PUBLIC
    end

  end
end
