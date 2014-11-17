FactoryGirl.define do
  factory :bookmarks_folder, aliases: [:item], class: Blacklight::Folders::FolderItem do
    association :folder
    association :bookmark
  end

  factory :bookmark do
    sequence(:document) {|n| SolrDocument.new(id: n) }
    user { FactoryGirl.create(:user) }
  end
end
