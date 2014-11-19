require 'rails_helper'

describe 'Editing a folder' do
  let(:user) { create :user }
  let(:document1) { SolrDocument.new(id: 'doc1', title_display: ['A title']) }
  let(:document2) { SolrDocument.new(id: 'doc2', title_display: ['Another title']) }

  let(:folder) { create(:folder, user: user) }
  let!(:destination_folder) { create(:folder, user: user, name: 'Destination Folder') }
  let(:bookmark1) { create(:bookmark, document: document1, user: user) }
  let(:bookmark2) { create(:bookmark, document: document2, user: user) }
  let!(:folder_item1) { create(:folder_item, bookmark: bookmark1, folder: folder) }
  let!(:folder_item2) { create(:folder_item, bookmark: bookmark2, folder: folder) }

  # routes { Blacklight::Folders::Engine.routes }

  before do
    Blacklight.solr.tap do |solr|
      solr.delete_by_query("*:*", params: { commit: true })
      solr.add [document1.to_h, document2.to_h]
      solr.commit
    end
    sign_in user
    visit blacklight_folders.folder_path(folder)
    click_link "Edit Folder"
  end

  it 'Should allow me to update the order of the folder items' do
    expect(page).to have_field 'folder[items_attributes][0][position]', with: '1'
    expect(page).to have_field 'folder[items_attributes][1][position]', with: '2'

    fill_in 'folder[items_attributes][1][position]', with: '0'

    click_button "Update Folder"

    expect(page).to have_content "The folder was successfully updated"

    # check that the second item is now the first.
    expect(page).to have_selector "#documents .document:first-of-type h5", text: 'Another title'
  end

  it "should allow me to remove folder items" do
    within "#documents li:first-of-type" do
      check 'Delete'
    end
    click_button "Update Folder"

    expect(page).to have_content "The folder was successfully updated"
    expect(page).not_to have_content "A title"
    expect(page).to have_selector "#documents .document", count: 1
  end

  it "should allow me to move items from one folder to another" do
    within "#documents li:first-of-type" do
      select 'Destination Folder', from: 'folder[items_attributes][0][folder_id]'
    end
    click_button "Update Folder"

    expect(page).to have_content "The folder was successfully updated"
    expect(page).not_to have_content "A title"
    expect(page).to have_selector "#documents .document", count: 1

    click_link 'Destination Folder'
    within '#documents' do
      expect(page).to have_content "A title"
    end
  end
end

