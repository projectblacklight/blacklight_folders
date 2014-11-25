require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject { Ability.new(current_user) }

  let(:you) { create(:user) }
  let(:private_folder) { create(:private_folder) }
  let(:your_private_folder) { create(:private_folder, user: you) }
  let(:your_public_folder) { create(:public_folder, user: you) }
  let(:your_public_item) { create(:item, folder: your_public_folder) }


  describe 'not logged in' do
    let(:current_user) { build(:guest_user) }

    it {
      should_not be_able_to :read,    your_private_folder
      should     be_able_to :show,    your_public_folder
      should_not be_able_to :destroy, your_public_folder
      should_not be_able_to :update,  your_public_folder
      should_not be_able_to :create,  Blacklight::Folders::Folder
      should     be_able_to :index,   Blacklight::Folders::Folder

      should_not be_able_to :destroy, your_public_item
      should     be_able_to :create,  Blacklight::Folders::FolderItem
    }

    context "when the folder is not persisted" do
      let(:my_folder) { current_user.folders.build }

      it {
        should_not be_able_to :show, my_folder
        should_not be_able_to :edit, my_folder
      }
    end

    context "after the folder is persisted" do
      let(:current_user) { create(:guest_user) }
      let(:my_folder) { current_user.folders.create(name: 'Default') }

      it {
        should be_able_to :show, my_folder
        should be_able_to :edit, my_folder
        should be_able_to :update_bookmarks, my_folder
      }
    end
  end


  describe 'logged in user' do

    let!(:me) { create(:user) }
    let!(:my_private_folder) { create(:private_folder, user: me) }
    let!(:my_private_item) { create(:item, folder: my_private_folder) }

    let(:current_user) { me }

    it {
      should_not be_able_to(:read, your_private_folder)
      should     be_able_to(:show, your_public_folder)
      should     be_able_to(:read, my_private_folder)

      should_not be_able_to(:destroy, your_public_folder)
      should     be_able_to(:destroy, my_private_folder)

      should_not be_able_to(:update, your_public_folder)
      should     be_able_to(:update, my_private_folder)

      should     be_able_to(:create, Blacklight::Folders::Folder)
      should     be_able_to(:index, Blacklight::Folders::Folder)

      should_not be_able_to(:destroy, your_public_item)
      should     be_able_to(:destroy, my_private_item)

      should     be_able_to(:create, Blacklight::Folders::FolderItem)
    }

    # This should never happen, but...
    # If the user_id of the bookmark doesn't match the user_id of
    # the folder, assume the folder's user_id is the correct one.
    describe 'special case where user_id of folder is out-of-sync with user_id of bookmark' do
      before do
        my_private_item.bookmark.user = you
        my_private_item.bookmark.save!
      end

      it {
        should_not be_able_to(:read, my_private_item)
        should_not be_able_to(:read, my_private_item.bookmark)
      }
    end
  end

end
