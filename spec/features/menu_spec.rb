require 'rails_helper'

describe 'Navbar menu' do
  let(:user) { FactoryGirl.create :user }

  it 'adds the "Folders" item to the existing blacklight menu' do
    sign_in user
    visit root_path

    # Menu items from blacklight
    expect(page).to have_link('Log Out', href: destroy_user_session_path)
    expect(page).to have_link('History', href: search_history_path)
    expect(page).to have_link('Saved Searches', href: saved_searches_path)

    # Menu items from blacklight_folders
    expect(page).to have_link('Folders', href: blacklight_folders.folders_path)
    expect(page).to have_link('Create a New Folder', href: blacklight_folders.new_folder_path)
  end
end
