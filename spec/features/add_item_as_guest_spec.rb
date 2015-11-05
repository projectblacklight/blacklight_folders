require 'rails_helper'

feature "Add an item to a folder from the show page", :js do
  let(:document1) { SolrDocument.new(id: 'doc1', title_display: ['First title']) }
  let(:user) { create(:user) }

  before do
    Blacklight.default_index.connection.tap do |solr|
      solr.delete_by_query("*:*", params: { commit: true })
      solr.add [document1.to_h]
      solr.commit
    end
  end

  it "should add the item to the default folder" do
    visit solr_document_path(document1)

    click_link 'Select a Folder'
    element = find('input#s2id_autogen1_search')
    element.native.send_key("Default folder")
    element.native.send_key(:Enter)
    click_button 'Add to Folder'

    within "#sidebar .folders" do
      expect(page).to have_link "Default folder"
    end

  end
end

