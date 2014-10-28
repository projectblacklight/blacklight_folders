require 'rails_helper'
require 'cancan/matchers'

describe Ability do

  let!(:me) { FactoryGirl.create(:user) }
  let!(:my_private_folder) { FactoryGirl.create(:private_folder, user: me) }

  let!(:you) { FactoryGirl.create(:user) }
  let!(:your_private_folder) { FactoryGirl.create(:private_folder, user: you) }
  let!(:your_public_folder) { FactoryGirl.create(:public_folder, user: you) }

  subject { Ability.new(current_user) }


  describe 'not logged in' do
    let(:current_user) { nil }

    it {
      should_not be_able_to(:read, your_private_folder)
      should     be_able_to(:read, your_public_folder)
      should_not be_able_to(:destroy, your_public_folder)
      should_not be_able_to(:update, your_public_folder)
      should_not be_able_to(:create, Blacklight::Folders::Folder)
    }
  end


  describe 'logged in user' do
    let(:current_user) { me }

    it {
      should_not be_able_to(:read, your_private_folder)
      should     be_able_to(:read, your_public_folder)
      should     be_able_to(:read, my_private_folder)

      should_not be_able_to(:destroy, your_public_folder)
      should     be_able_to(:destroy, my_private_folder)

      should_not be_able_to(:update, your_public_folder)
      should     be_able_to(:update, my_private_folder)

      should     be_able_to(:create, Blacklight::Folders::Folder)
    }
  end

end
