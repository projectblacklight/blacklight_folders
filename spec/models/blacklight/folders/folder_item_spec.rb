require 'rails_helper'

module Blacklight::Folders
  RSpec.describe FolderItem, :type => :model do
    let(:subject) { FactoryGirl.build(:folder_item) }

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
      item = Blacklight::Folders::FolderItem.new(folder_id: 1, document_id: 'id:123', document_type: nil)
      item.save!
      expect(item.document_type).to eq 'SolrDocument'
    end
  end
end
