require_dependency "blacklight/folders/application_controller"

module Blacklight::Folders
  class FoldersController < ApplicationController
    include Blacklight::TokenBasedUser
    include Blacklight::Catalog::SearchContext
    include Blacklight::Catalog::IndexTools

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
      if @folder.update(preprocess_nested_attributes(create_params))
        respond_to do |format|
          format.html do
            redirect_to @folder, notice: t(:'helpers.submit.folder.updated')
          end
          format.json do
            render json: @folder
          end
        end
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

      def preprocess_nested_attributes(in_params)
        return in_params unless in_params.key?(:items_attributes)
        in_params.merge(items_attributes: reorder_items(strip_blank_folders(nested_params_to_array(in_params[:items_attributes]))))
      end

      def nested_params_to_array(attributes_collection)
        if attributes_collection.is_a? Hash
          keys = attributes_collection.keys
          attributes_collection = if keys.include?('id') || keys.include?(:id)
            [attributes_collection]
          else
            attributes_collection.values
          end
        end
        attributes_collection
      end

      def strip_blank_folders(attributes_collection)
        attributes_collection.each do |record_attributes|
          record_attributes.delete(:folder_id) if record_attributes[:folder_id].blank?
        end
        attributes_collection
      end

      def reorder_items(attributes_collection)
        # This mutates the hashes inside the list
        attributes_collection.sort { |a, b| a[:position].to_i <=> b[:position].to_i }.
          each_with_index do |record_attributes, i|
            if record_attributes[:folder_id]
              # when moving an item to a different folder acts_as_list will
              # send it to the end if we don't try to set the position..
              record_attributes.delete(:position)
            else
              record_attributes[:position] = i + 1
            end
          end
        attributes_collection
      end

      def _prefixes
	      @_prefixes ||= super + ['catalog']
	    end

      def create_params
        params.require(:folder).permit(:name, :visibility, items_attributes: [:id, :position, :_destroy, :folder_id])
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
