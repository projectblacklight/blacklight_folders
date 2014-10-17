require 'rails_helper'

describe Blacklight::Folders::Folder do

  let(:subject) { FactoryGirl.build(:folder) }

  it 'a factory-created folder is valid' do
    folder = FactoryGirl.build(:folder)
    expect(folder.valid?).to eq true
  end

  it 'requires a user' do
    expect(subject.valid?).to eq true
    subject.user = nil
    expect(subject.valid?).to eq false
    expect(subject.errors.messages[:user_id].first).to match /blank/
  end

  it 'requires a name' do
    expect(subject.valid?).to eq true
    subject.name = nil
    expect(subject.valid?).to eq false
    expect(subject.errors.messages[:name].first).to match /blank/
  end

end
