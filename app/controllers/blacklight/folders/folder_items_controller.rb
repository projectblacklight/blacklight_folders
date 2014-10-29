require_dependency "blacklight/folders/application_controller"

module Blacklight::Folders
  class FolderItemsController < ApplicationController
    load_and_authorize_resource class: Blacklight::Folders::FolderItem

    def create
      if @folder_item.save
        redirect_to :back
      else
        render :new
      end
    end

    private

      def create_params
        params.require(:folder_item).permit(:folder_id, :document_id)
      end
  end
end
