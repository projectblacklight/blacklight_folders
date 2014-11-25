require 'rails_helper'

feature "Persist folders after logging in", :js do
  let(:document1) { SolrDocument.new(id: 'doc1', title_display: ['First title']) }
  let(:document2) { SolrDocument.new(id: 'doc2', title_display: ['Second title']) }
  let(:document3) { SolrDocument.new(id: 'doc3', title_display: ['Third title']) }

  let(:user) { create(:user) }

  before do
    Blacklight.solr.tap do |solr|
      solr.delete_by_query("*:*", params: { commit: true })
      solr.add [document1.to_h, document2.to_h, document3.to_h]
      solr.commit
    end

    user.folders.first.update(name: 'Something besides the default')

  end

  it "should carry over my selections after logging in" do
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

    click_link "Login"

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
    expect(page).to have_content "Signed in successfully."

    click_link "Folders"
    click_link "Default folder"

    expect(page).to     have_content 'First title'
    expect(page).not_to have_content 'Second title'
    expect(page).to     have_content 'Third title'

  end
end
