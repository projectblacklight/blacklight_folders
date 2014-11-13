require 'rails_helper'

module Blacklight::Folders
  RSpec.describe FolderItem, :type => :model do
    subject { FactoryGirl.build(:folder_item) }

    it 'factory creates a valid object' do
      item = FactoryGirl.create(:item)
      expect(item.valid?).to eq true
    end

    it 'belongs to a folder' do
      expect(subject.valid?).to eq true
      subject.folder = nil
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:folder_id].first).to match /blank/
    end

    it 'points to a document' do
      expect(subject.valid?).to eq true
      subject.document_id = nil
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:document_id].first).to match /blank/
    end

    it 'sets the document type automatically' do
      item = Blacklight::Folders::FolderItem.new(folder: FactoryGirl.create(:folder), document_id: 'id:123', document_type: nil)
      item.save!
      expect(item.document_type).to eq 'SolrDocument'
    end

    context "when an item moves from one folder to another" do
      let(:folder1) { FactoryGirl.create(:folder) }
      let(:folder2) { FactoryGirl.create(:folder) }
      subject! { FactoryGirl.create(:folder_item, folder: folder1) }
      it "should update the count on each folder" do
        expect { subject.update(folder: folder2) }.to change {
          folder1.reload.number_of_members }.from(1).to(0).and change {
          folder2.reload.number_of_members }.from(0).to(1)
      end
    end
  end
end
