require 'rails_helper'

describe Blacklight::Folders::Folder do
  let(:user) { FactoryGirl.create(:user) }

  it 'requires a user' do
    expect(subject.valid?).to eq false
    expect(subject.errors.messages[:user_id].first).to match /blank/
    subject.user = user
    expect(subject.valid?).to eq true
  end

end
