require_dependency "blacklight/folders/application_controller"

module Blacklight::Folders
  class FoldersController < ApplicationController
    before_action :set_folder, only: [:show, :edit, :update, :destroy]

    def show
    end

    def new
      @folder = Folder.new
    end

    def edit
    end

    def create
      @folder = Folder.new(folder_params)
      @folder.user = current_user

      if @folder.save
        redirect_to @folder, notice: 'Folder was successfully created.'
      else
        render :new
      end
    end

    def update
      if @folder.update(folder_params)
        redirect_to @folder
      else
        render :edit
      end
    end

    def destroy
      @folder.destroy
      redirect_to main_app.root_path, notice: "Folder #{@folder.name} was successfully deleted."
    end

    private

      def set_folder
        @folder = Folder.find(params[:id])
      end

      def folder_params
        params.require(:folder).permit(:name)
      end

  end
end
