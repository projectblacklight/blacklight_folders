require 'rails_helper'
require_relative '../../../lib/migration/bookmark_migrator'

describe BookmarkMigrator do

  describe 'existing users with existing bookmarks' do
    let!(:pippin) { FactoryGirl.create(:user) }

    let!(:bilbo) do
      bilbo = FactoryGirl.create(:user)
      3.times { FactoryGirl.create(:bookmark, user: bilbo) }
      bilbo
    end

    let!(:frodo) do
      frodo = FactoryGirl.create(:user)
      2.times { FactoryGirl.create(:bookmark, user: frodo) }
      frodo
    end

    describe 'with no existing folders:' do
      before do
        # Remove default folders to make the test resemble the
        # state the database would be in when you are first
        # installing blacklight_folders (i.e. no folders exist
        # yet.)
        Blacklight::Folders::Folder.destroy_all
      end

      it 'for each user, creates a default folder and adds bookmarks to it' do
        # Make sure test is set up properly
        expect(User.count).to eq 3
        expect(Blacklight::Folders::Folder.count).to eq 0
        expect(Blacklight::Folders::FolderItem.count).to eq 0
        expect(bilbo.bookmarks.count).to eq 3
        expect(frodo.bookmarks.count).to eq 2

        BookmarkMigrator.new.migrate

        # Creates default folders for each user
        expect(Blacklight::Folders::Folder.count).to eq User.count

        # Adds existing bookmarks to the default folder
        frodos_items = frodo.folders.first.items
        expect(frodos_items.map(&:bookmark).sort).to eq frodo.bookmarks.sort
        expect(frodos_items.count).to eq 2
        expect(frodo.folders.first.number_of_members).to eq 2

        bilbos_items = bilbo.folders.first.items
        expect(bilbos_items.map(&:bookmark).sort).to eq bilbo.bookmarks.sort
        expect(bilbos_items.count).to eq 3
        expect(bilbo.folders.first.number_of_members).to eq 3
      end

      it 'logs errors if it fails to save the items' do
        allow_any_instance_of(Blacklight::Folders::Folder).to receive(:save) { false }
        migrator = BookmarkMigrator.new
        status = migrator.migrate
        expect(status).to eq false
        expect(migrator.errors.count).to eq 3
        expect(migrator.errors.first).to match /Unable to save bookmarks to folder/
      end
    end  # with no existing folders

    describe 'with existing folders:' do

      it 'does not create extra folders for users that already have a default folder' do
        count = User.count
        expect(Blacklight::Folders::Folder.count).to eq count
        BookmarkMigrator.new.migrate
        expect(Blacklight::Folders::Folder.count).to eq count
      end

      it 'does not duplicate bookmarks if they are already in the folder' do
        # A user with bookmarks in a folder
        folder = bilbo.folders.first
        count = bilbo.bookmarks.count
        folder.items.build(bookmark: bilbo.bookmarks.first)
        folder.save!
        expect(folder.items.count).to eq 1

        BookmarkMigrator.new.migrate
        expect(folder.items.count).to eq count
        expect(folder.items.map(&:bookmark).sort).to eq bilbo.bookmarks.sort
      end
    end  # with existing folders

  end  # existing users with existing bookmarks

end
