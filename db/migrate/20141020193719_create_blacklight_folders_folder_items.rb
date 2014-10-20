class CreateBlacklightFoldersFolderItems < ActiveRecord::Migration
  def change
    create_table :blacklight_folders_folder_items do |t|
      t.references :folder, null: false, index: true
      t.integer :position
      t.references :document, null: false, polymorphic: true

      t.timestamps
    end
  end
end
