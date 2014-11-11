module Blacklight::Folders
  module FoldersHelper

    def human_friendly_visibility(visibility)
      case visibility
      when Blacklight::Folders::Folder::PUBLIC
        'visible to anyone'
      when Blacklight::Folders::Folder::PRIVATE
        'private to me'
      else
        visibility
      end
    end

  end
end
