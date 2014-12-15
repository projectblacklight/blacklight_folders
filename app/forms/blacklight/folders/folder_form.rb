module Blacklight::Folders
  class FolderForm
    def initialize(params)
      @params = params
    end

    def update(folder)
      folder.assign_attributes(preprocess_nested_attributes(@params))
      reorder_items(folder)
      folder.save
    end

    protected
      def preprocess_nested_attributes(in_params)
        return in_params unless in_params.key?(:items_attributes)
        in_params.merge(items_attributes: strip_blank_folders(nested_params_to_array(in_params[:items_attributes])))
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

      # This updates the positions of the folder items
      def reorder_items(folder)
        # we have to do a sort_by, not order, because the updated attributes have not been saved.
        changed_folder, new, changed_position, unchanged = folder.items.
          sort_by(&:position).
          group_by do |item|
            if item.folder_id_was != item.folder_id
              :changed_folder
            elsif item.position_was.nil?
              :new
            elsif item.position_was != item.position
              :changed_position
            else
              :unchanged
            end
        end.values_at(:changed_folder, :new, :changed_position, :unchanged).map(&:to_a)

        # items that will be in this folder
        unmoved_items = unchanged
        # place items whose positions were specified
        changed_position.map {|item| unmoved_items.insert(item.position - 1, item)}
        # add new items at the end
        unmoved_items = unmoved_items + new
        # calculate positions
        unmoved_items.compact.
          select {|item| item.folder_id_was == item.folder_id}.
          each_with_index do |item, position|
            item.position = position + 1
          end

        # items that have moved to another folder
        changed_folder.select {|item| item.folder_id_was != item.folder_id}.each do |item|
          item.position = nil
        end
      end
  end
end
