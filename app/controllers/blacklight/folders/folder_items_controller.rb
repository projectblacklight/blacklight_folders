require_dependency "blacklight/folders/application_controller"

module Blacklight::Folders
  class FolderItemsController < ApplicationController

    def create
      @folder_item = FolderItem.new(folder_item_params)
      if @folder_item.save
        redirect_to :back
      else
        render :new
      end
    end

    private

    def folder_item_params
      params.require(:folder_item).permit(:folder_id, :document_id)
    end
  end
end
