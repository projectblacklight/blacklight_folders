class AddDescriptionToFolders < ActiveRecord::Migration
  def change
     add_column :blacklight_folders_folders, :description, :text
  end
end
