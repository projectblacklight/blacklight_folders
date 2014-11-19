require 'rails_helper'

describe 'blacklight/nav/_folders' do
  let(:user) { User.new }

  before do
    allow(view).to receive_message_chain(:current_user, :folders, :most_recent, :limit).and_return([])
    allow(view).to receive_message_chain(:current_user, :folders, :count).and_return(count)
    render
  end

  context "with five folders" do
    let(:count) { 5 }
    it "should not have 'Show all folders'" do
      expect(rendered).not_to have_link 'Show All', href: blacklight_folders.folders_path
    end
  end

  context "with six folders" do
    let(:count) { 6 }
    it "should have 'Show all folders'" do
      expect(rendered).to have_link 'Show All', href: blacklight_folders.folders_path
    end
  end
end
