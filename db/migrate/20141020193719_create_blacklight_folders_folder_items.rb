class CreateBlacklightFoldersFolderItems < ActiveRecord::Migration
  def change
    create_table :blacklight_folders_folder_items do |t|
      t.references :folder, null: false, index: true
      t.integer :position
      t.string :document_id, null: false, index: true
      t.string :document_type

      t.timestamps
    end
  end
end
