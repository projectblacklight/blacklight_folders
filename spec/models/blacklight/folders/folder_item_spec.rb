require 'rails_helper'

module Blacklight::Folders
  RSpec.describe FolderItem, :type => :model do

    it 'belongs to a folder' do
      subject.folder = nil
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:folder_id].first).to match /blank/
    end

    it 'belongs to a bookmark' do
      subject.bookmark = nil
      expect(subject.valid?).to eq false
      expect(subject.errors.messages[:bookmark_id].first).to match /blank/
    end

    context "when an item moves from one folder to another" do
      let(:folder1) { create(:folder) }
      let(:folder2) { create(:folder) }
      subject! { create(:folder_item, folder: folder1) }
      it "should update the count on each folder" do
        expect { subject.update(folder: folder2) }.to change {
          folder1.reload.number_of_members }.from(1).to(0).and change {
          folder2.reload.number_of_members }.from(0).to(1)
      end
    end
  end
end
