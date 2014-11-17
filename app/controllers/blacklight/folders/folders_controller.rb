require_dependency "blacklight/folders/application_controller"

module Blacklight::Folders
  class FoldersController < ApplicationController
    include EncryptedUser
    include Blacklight::Catalog::SearchContext
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
      if @folder.update(reorder_items(create_params))
        redirect_to @folder, notice: t(:'helpers.submit.folder.updated')
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

      def reorder_items(in_params)
        return in_params unless in_params.key?(:items_attributes)
        attributes_collection = in_params[:items_attributes]
        if attributes_collection.is_a? Hash
          keys = attributes_collection.keys
          attributes_collection = if keys.include?('id') || keys.include?(:id)
            [attributes_collection]
          else
            attributes_collection.values
          end
        end

        # This mutates the hashes inside the list
        attributes_collection.sort { |a, b| a[:position].to_i <=> b[:position].to_i }.
          each_with_index do |record_attributes, i|
            record_attributes[:position] = i + 1
          end


        in_params.merge(items_attributes: attributes_collection)
      end

      def _prefixes
	      @_prefixes ||= super + ['catalog']
	    end

      def create_params
        params.require(:folder).permit(:name, :visibility, items_attributes: [:id, :position, :_destroy])
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
