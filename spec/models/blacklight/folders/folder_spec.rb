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

  describe '.without_doc_for_user' do
    let!(:my_folder)   { FactoryGirl.create(:folder) }
    let!(:your_folder) { FactoryGirl.create(:folder) }
    let!(:me)  { my_folder.user }
    let!(:you) { your_folder.user }

    let(:doc) { SolrDocument.new(id: '12345') }
    let!(:my_item) { FactoryGirl.create(:item, folder: my_folder) }
    let!(:your_item) { FactoryGirl.create(:item, folder: your_folder) }

    it 'finds only my folders' do
      mine = Blacklight::Folders::Folder.without_doc_for_user(doc, me)
      yours = Blacklight::Folders::Folder.without_doc_for_user(doc, you)
      expect(mine).to eq [my_folder]
      expect(yours).to eq [your_folder]
    end

    it "finds only the folders that don't contain the doc" do
      my_folder_with_doc = FactoryGirl.create(:folder, user: me)
      my_item_with_doc = FactoryGirl.create(:item, folder: my_folder_with_doc, document: doc)
      my_folders = Blacklight::Folders::Folder.where(user_id: me.id)
      expect(my_folders.map(&:id).sort).to eq [my_folder.id, my_folder_with_doc.id].sort

      result = Blacklight::Folders::Folder.without_doc_for_user(doc, me)
      expect(result).to eq [my_folder]
    end
  end

end
