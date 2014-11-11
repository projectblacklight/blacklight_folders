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

  describe '#documents' do
    let(:subject) { FactoryGirl.create(:folder) }

    describe 'a folder with items in it' do
      let(:doc_ddh) { SolrDocument.new(id: 'U DDH') }
      let(:doc_123) { SolrDocument.new(id: 'pid:1.2.3') }
      let(:not_my_doc) { SolrDocument.new(id: 'xyz') }

      let!(:item_ddh) { FactoryGirl.create(:item, folder: subject, document: doc_ddh, position: 2) }
      let!(:item_123) { FactoryGirl.create(:item, folder: subject, document: doc_123, position: 1) }

      before do
        Blacklight.solr.delete_by_query("*:*", params: { commit: true })
        Blacklight.solr.add(id: doc_ddh.id)
        Blacklight.solr.add(id: doc_123.id)
        Blacklight.solr.add(id: not_my_doc.id)
        Blacklight.solr.commit
      end

      after do
        Blacklight.solr.delete_by_id(doc_ddh.id)
        Blacklight.solr.delete_by_id(doc_123.id)
        Blacklight.solr.delete_by_id(not_my_doc.id)
        Blacklight.solr.commit
      end

      it 'returns the documents for this folder in order' do
        expect(subject.items.count).to eq 2
        expect(subject.documents.map{|doc| doc['id']}).to eq [doc_123.id, doc_ddh.id]
      end

      it 'returns SolrDocuments' do
        expect(subject.documents.first.class).to eq ::SolrDocument
      end
    end

    describe 'an empty folder' do
      it 'returns empty array' do
        expect(subject.documents).to eq []
      end
    end

    describe 'Visibility' do
      it 'default visibility is private' do
        expect(subject.default_visibility).to eq Blacklight::Folders::Folder::PRIVATE
      end

      it 'sets visibility to default value if none given' do
        subject.visibility = nil
        subject.save!
        expect(subject.reload.visibility).to eq subject.default_visibility
      end
    end
  end

end
