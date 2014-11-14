class CreateBlacklightFoldersBookmarksFolders < ActiveRecord::Migration

  def change
    create_table :blacklight_folders_bookmarks_folders do |t|
      t.references :folder, null: false, index: true
      t.references :bookmark, null: false, index: true
      t.integer :position

      t.timestamps
    end
  end

end
