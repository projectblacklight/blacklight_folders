class AddSizeToFolders < ActiveRecord::Migration
  def change
    add_column :blacklight_folders_folders, :number_of_members, :integer, default: 0, null: false
  end
end
