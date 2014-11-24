require 'rails_helper'

describe 'blacklight/nav/_folders' do
  let(:user) { User.new }

  before do
    allow(view).to receive_message_chain(:current_user, :folders, :most_recent, :limit).and_return([])
    allow(view).to receive_message_chain(:current_user, :folders, :count).and_return(1)
    render
  end

  it "should have 'Show all folders'" do
    expect(rendered).to have_link 'Show All', href: blacklight_folders.folders_path
  end
end
