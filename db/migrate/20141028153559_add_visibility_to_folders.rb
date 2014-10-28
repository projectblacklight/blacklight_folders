class AddVisibilityToFolders < ActiveRecord::Migration
  def change
    add_column :blacklight_folders_folders, :visibility, :string
  end
end
