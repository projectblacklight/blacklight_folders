require 'rails_helper'

describe 'blacklight/nav/_folders' do
  before do
    allow(view).to receive_message_chain(:current_or_guest_user, :folders, :most_recent, :limit).and_return([])
    allow(view).to receive_message_chain(:current_or_guest_user, :folders, :size).and_return(1)
    allow(view).to receive(:can?).with(:create, Blacklight::Folders::Folder).and_return(true)
    render
  end

  it "should have 'Show all folders'" do
    expect(rendered).to have_link 'Show All', href: blacklight_folders.folders_path
  end
end
