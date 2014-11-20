require 'rails_helper'

describe 'Add an item to a folder' do
  let(:user) { create :user }
  let(:document1) { SolrDocument.new(id: 'doc1', title_display: ['A title']) }

  let!(:folder1) { create(:folder, user: user, name: 'Folder 1') }
  let!(:folder2) { create(:folder, user: user, name: 'Folder 2') }

  before do
    Blacklight.solr.tap do |solr|
      solr.delete_by_query("*:*", params: { commit: true })
      solr.add [document1.to_h]
      solr.commit
    end
    sign_in user
    visit solr_document_path(document1)
  end

  it 'Should allow me to add item to a folder' do
    within '#sidebar' do
      expect(page).not_to have_selector '.panel.folders'

      within '.show-tools' do
        select 'Folder 1', from: 'folder_id'
        click_button 'Add to Folder'
      end
    end

    within '.panel.folders' do
      expect(page).to have_link 'Folder 1'
    end

  end
end

