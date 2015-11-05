require 'rails_helper'

feature "Persist folders after logging in", :js do
  let(:document1) { SolrDocument.new(id: 'doc1', title_display: ['First title']) }
  let(:document2) { SolrDocument.new(id: 'doc2', title_display: ['Second title']) }
  let(:document3) { SolrDocument.new(id: 'doc3', title_display: ['Third title']) }

  let(:user) { create(:user) }

  before do
    Blacklight.default_index.connection.tap do |solr|
      solr.delete_by_query("*:*", params: { commit: true })
      solr.add [document1.to_h, document2.to_h, document3.to_h]
      solr.commit
    end
  end

  describe 'when the user has no default folder:' do
    before do
      user.folders.first.update(name: 'Something besides the default')
    end

    it "should carry over my selections after logging in" do
      bookmark_two_documents
      log_in_to_my_account

      click_link "Folders"
      click_link "Default folder"

      expect(page).to     have_content 'First title'
      expect(page).not_to have_content 'Second title'
      expect(page).to     have_content 'Third title'
    end
  end


  describe 'when the user already has a default folder:' do
    before do
      user.folders.first.bookmarks.create!(document_id: document2.id, user_id: user.id, document_type: 'SolrDocument')
    end

    it "should add my selections to the existing default folder after logging in" do
      expect(user.folders.count).to eq 1
      expect(user.folders.first.bookmarks.count).to eq 1
      expect(user.folders.first.items.count).to eq 1

      bookmark_two_documents
      log_in_to_my_account

      expect(user.folders.count).to eq 1
      expect(user.folders.first.bookmarks.count).to eq 3

      # It should clean up the (now empty) guest user's folder
      expect(Blacklight::Folders::Folder.count).to eq 1

      # The existing bookmark should be first.  The new
      # bookmarks should be added at the end of the list.
      expect(user.folders.first.bookmarks.first.document_id).to eq document2.id

      click_link "Folders"
      click_link "Default folder"

      expect(page).to have_content 'First title'
      expect(page).to have_content 'Second title'
      expect(page).to have_content 'Third title'
    end
  end

end

def bookmark_two_documents
  visit root_path
  click_button "Search"
  within ".document:first-child" do
    check 'folder_ids[]'
  end
  within ".document:last-child" do
    check 'folder_ids[]'
  end
  click_link 'Add to folder'
  element = find('input#s2id_autogen1_search')
  element.native.send_key("Default folder")
  element.native.send_key(:Enter)
  expect(page).to have_content "Added documents to Default folder"
end

def log_in_to_my_account
  click_link "Login"
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Log in"
  expect(page).to have_content "Signed in successfully."
end
