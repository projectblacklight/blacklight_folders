require_dependency "blacklight/folders/application_controller"

module Blacklight::Folders
  class FoldersController < ApplicationController
    include EncryptedUser
    load_and_authorize_resource class: Blacklight::Folders::Folder, except: [:add_bookmarks, :remove_bookmarks]
    before_filter :load_and_authorize_folder, only: [:add_bookmarks, :remove_bookmarks]
    before_filter :clear_session_search_params, only: [:show]

    def index
      @folders = Blacklight::Folders::Folder.accessible_by(current_ability)
      @folders = @folders.order(params[:order_by]) if params[:order_by]
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

    def add_bookmarks
      doc_ids = Array(params['document_ids'].split(',').map(&:strip))
      @folder.add_bookmarks(doc_ids)

      if @folder.save
        redirect_to :back
      else
        redirect_to :back, alert: 'Unable to save bookmarks.'
      end
    end

    def remove_bookmarks
      item_ids = Array(params['item_ids'].split(',').map(&:to_i))
      items = @folder.items.select {|x| item_ids.include?(x.id)}
      @folder.remove_bookmarks(items)
      redirect_to :back
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

      def load_and_authorize_folder
        @folder = Folder.find(params['id']) if params['id']
        @folder ||= Folder.find(params['folder']['id'])
        authorize! :edit, @folder
      end

  end
end
