require 'rails_helper'

describe Blacklight::Folders::Folder do

  let(:subject) { build(:folder) }

  it 'requires a user' do
    expect(subject.valid?).to eq true
    subject.user = nil
    expect(subject.valid?).to eq false
    expect(subject.errors.messages[:user].first).to match /blank/
  end

  it 'requires a name' do
    expect(subject.valid?).to eq true
    subject.name = nil
    expect(subject.valid?).to eq false
    expect(subject.errors.messages[:name].first).to match /blank/
  end

  it 'has number_of_members which defaults to 0' do
    expect(subject.number_of_members).to eq 0
  end

  it 'contains items, listed in order' do
    subject.save!
    item_A = FactoryGirl.create(:item, folder: subject, position: 1)
    item_B = FactoryGirl.create(:item, folder: subject, position: 2)
    expect(subject.items.map(&:id)).to eq [item_A.id, item_B.id]
  end

  describe '#updated_at' do
    let(:updated_at) { 1.day.ago }
    let(:subject) { FactoryGirl.create(:folder, updated_at: updated_at) }
    let(:doc_ddh) { SolrDocument.new(id: 'U DDH', title_t: ['A title']) }
    let(:doc_123) { SolrDocument.new(id: 'pid:1.2.3', title_t: ['Another title']) }
    let(:doc_456) { SolrDocument.new(id: 'pid:4.5.6', title_t: ['Yet another title']) }
    before do
      subject.add_bookmarks([doc_ddh.id, doc_123.id])
      subject.updated_at = updated_at
      subject.save!
    end

    it 'changes when adding a bookmark' do
      subject.add_bookmarks([doc_456.id])
      subject.save!
      subject.reload
      expect(subject.updated_at).to be > updated_at
    end

    it 'changes when removing a bookmark' do
      subject.remove_bookmarks([subject.items.first])
      subject.save!
      subject.reload
      expect(subject.updated_at).to be > updated_at
    end

    it 'changes when reordering bookmarks' do
      subject.items.sort_by(&:position).reverse.each_with_index do |item, pos|
        item.position = pos + 1
      end
      subject.save!
      subject.reload
      expect(subject.updated_at).to be > updated_at
    end
  end

  describe '.most_recent' do
    let(:user) { create(:user) }
    let!(:my_default_folder) { user.folders.first }
    let!(:newest_folder) { create(:folder, user: user) }
    let!(:oldest_folder) { create(:folder, updated_at: 5.days.ago, user: user) }
    let!(:middle_folder) { create(:folder, updated_at: 3.days.ago, user: user) }

    it 'orders folders by update date' do
      expect(user.folders.most_recent).to eq [newest_folder, my_default_folder, middle_folder, oldest_folder]
    end
  end

  context "with a folder that has a document and an empty folder" do
    let(:me) { create(:user) }
    let!(:my_folder) { me.folders.first }

    let(:doc) { SolrDocument.new(id: '12345') }
    let!(:my_item) { create(:item, folder: my_folder) }

    let(:folder_with_doc) { create(:folder, user: me) }

    before { folder_with_doc.bookmarks.create(document: doc, user: me) }

    describe '.without_document' do
      subject { Blacklight::Folders::Folder.without_document(doc) }
      it { is_expected.not_to include folder_with_doc }
    end

    describe '.with_document' do
      subject { Blacklight::Folders::Folder.with_document(doc) }
      it { is_expected.to eq [folder_with_doc] }
    end
  end

  describe '.for_user' do
    let(:me) { create(:user) }
    let!(:my_folder) { me.folders.first }
    let(:you) { create(:user) }
    let!(:your_folder) { you.folders.first }

    subject { Blacklight::Folders::Folder.for_user(me) }
    it { is_expected.to eq [my_folder] }
  end

  describe '#documents' do
    let(:subject) { FactoryGirl.create(:folder) }

    describe 'a folder with items in it' do
      let(:doc_ddh) { SolrDocument.new(id: 'U DDH', title_t: ['A title']) }
      let(:doc_123) { SolrDocument.new(id: 'pid:1.2.3', title_t: ['Another title']) }
      let(:not_my_doc) { SolrDocument.new(id: 'xyz') }

      before do
        b1 = FactoryGirl.create(:bookmark, document_id: doc_ddh.id, user_id: subject.user_id, document_type: 'SolrDocument')
        b2 = FactoryGirl.create(:bookmark, document_id: doc_123.id, user_id: subject.user_id, document_type: 'SolrDocument')
        subject.items.build([{ bookmark: b1, position: 2 }, { bookmark: b2, position: 1 }])
        subject.save!


        Blacklight.solr.delete_by_query("*:*", params: { commit: true })
        Blacklight.solr.add(doc_ddh.to_h)
        Blacklight.solr.add(doc_123.to_h)
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
        expect(subject.documents.map{|doc| doc['title_t']}).to eq [doc_123['title_t'], doc_ddh['title_t']]
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
        expect(subject.send(:default_visibility)).to eq Blacklight::Folders::Folder::PRIVATE
      end

      it 'sets visibility to default value if none given' do
        subject.visibility = nil
        subject.save!
        expect(subject.reload.visibility).to eq Blacklight::Folders::Folder::PRIVATE
      end
    end
  end

  describe '#add_bookmarks' do
    before do
      subject.bookmarks.build([document_id: 'first', document_type: 'SolrDocument', user_id: subject.user_id])
      subject.save!
    end

    it 'appends bookmarks to the exising list' do
      bookmarks_count = Bookmark.count
      subject.add_bookmarks(['1', '2', '3'])
      subject.save!
      expect(Bookmark.count). to eq bookmarks_count + 3
      expect(subject.bookmarks.map(&:document_id)[-3..-1]).to eq ['1', '2', '3']
    end

    it 'sets the correct user_id' do
      expect(subject.bookmarks.count).to eq 1
      expect(subject.bookmarks.first.user_id).to eq subject.user_id
    end

    it 'sets document_type' do
      subject.add_bookmarks(['1'])
      subject.save!
      expect(subject.bookmarks.count).to eq 2
      expect(subject.bookmarks.map(&:document_type)).to eq [SolrDocument, SolrDocument]
    end
  end

  describe '#remove_bookmarks' do
    let(:subject) { FactoryGirl.create(:folder) }

    before do
      b123 = FactoryGirl.create(:bookmark, document_id: '123', user_id: subject.user_id)
      b456 = FactoryGirl.create(:bookmark, document_id: '456', user_id: subject.user_id)
      b789 = FactoryGirl.create(:bookmark, document_id: '789', user_id: subject.user_id)

      @item_123 = FactoryGirl.create(:item, bookmark: b123, folder: subject)
      @item_456 = FactoryGirl.create(:item, bookmark: b456, folder: subject)
      @item_789 = FactoryGirl.create(:item, bookmark: b789, folder: subject)
    end

    it 'removes the bookmarks' do
      expect(Bookmark.count).to eq 3
      expect(Blacklight::Folders::FolderItem.count).to eq 3

      list_to_remove = [@item_789, @item_123]

      subject.remove_bookmarks(list_to_remove)

      expect(Bookmark.count).to eq 1
      expect(subject.bookmarks.map(&:document_id)).to eq ['456']
      expect(Blacklight::Folders::FolderItem.count).to eq 1
    end
  end

end
