require_dependency "blacklight/folders/application_controller"

module Blacklight::Folders
  class FoldersController < ApplicationController
    load_and_authorize_resource class: Blacklight::Folders::Folder
    before_filter :clear_session_search_params, only: [:show]

    def index
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      @folder.user = current_user
      if @folder.save
        redirect_to @folder
      else
        render :new
      end
    end

    def update
      if @folder.update(create_params)
        redirect_to @folder
      else
        render :edit
      end
    end

    def destroy
      @folder.destroy
      redirect_to main_app.root_path, notice: "Folder \"#{@folder.name}\" was successfully deleted."
    end

    private

      def _prefixes
	      @_prefixes ||= super + ['catalog']
	    end

      def create_params
        params.require(:folder).permit(:name, :visibility)
      end

      def clear_session_search_params
        # TODO: Is there a blacklight method we can use to do this?
        session['search'] = nil
      end

  end
end
