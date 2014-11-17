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

  it 'has number_of_members which defaults to 0' do
    expect(subject.number_of_members).to eq 0
  end

  it 'contains items, listed in order' do
    subject.save!
    item_A = FactoryGirl.create(:item, folder: subject, position: 1)
    item_B = FactoryGirl.create(:item, folder: subject, position: 2)
    expect(subject.items.map(&:id)).to eq [item_A.id, item_B.id]
  end

  describe '.most_recent' do
    before do
      @user = FactoryGirl.create(:user)
      @newest_folder = FactoryGirl.create(:folder, user: @user)
      @oldest_folder = FactoryGirl.create(:folder, updated_at: 5.days.ago, user: @user)
      @middle_folder = FactoryGirl.create(:folder, updated_at: 3.days.ago, user: @user)
    end

    it 'orders folders by update date' do
      expect(@user.folders.most_recent).to eq [@newest_folder, @middle_folder, @oldest_folder]
    end
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
      my_bookmark_with_doc = my_folder_with_doc.bookmarks.create(document: doc, user: me)

      my_folders = Blacklight::Folders::Folder.where(user_id: me.id)
      expect(my_folders.map(&:id).sort).to eq [my_folder.id, my_folder_with_doc.id].sort

      result = Blacklight::Folders::Folder.without_doc_for_user(doc, me)
      expect(result).to eq [my_folder]
    end
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
        expect(subject.default_visibility).to eq Blacklight::Folders::Folder::PRIVATE
      end

      it 'sets visibility to default value if none given' do
        subject.visibility = nil
        subject.save!
        expect(subject.reload.visibility).to eq subject.default_visibility
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
      expect(Blacklight::Folders::BookmarksFolder.count).to eq 3

      list_to_remove = [@item_789, @item_123]

      subject.remove_bookmarks(list_to_remove)

      expect(Bookmark.count).to eq 1
      expect(subject.bookmarks.map(&:document_id)).to eq ['456']
      expect(Blacklight::Folders::BookmarksFolder.count).to eq 1
    end
  end

end
