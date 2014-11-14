require 'rails_helper'

module Blacklight::Folders
  RSpec.describe BookmarksFolder, :type => :model do

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

  end
end
