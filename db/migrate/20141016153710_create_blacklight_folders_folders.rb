class CreateBlacklightFoldersFolders < ActiveRecord::Migration
  def change
    create_table :blacklight_folders_folders do |t|
      t.string :name
      t.string :user_id

      t.timestamps
    end
  end
end
