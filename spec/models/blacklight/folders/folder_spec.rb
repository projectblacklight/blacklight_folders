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

  it 'contains items, listed in order' do
    subject.save!
    attrs = FactoryGirl.attributes_for(:item)
    item_A = subject.items.create!(attrs.merge(position: 2))
    item_B = subject.items.create!(attrs.merge(position: 1))

    expect(subject.items).to eq [item_B, item_A]
  end

end
