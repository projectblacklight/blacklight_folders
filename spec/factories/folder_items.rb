FactoryGirl.define do
  factory :folder_item, aliases: [:item], class: Blacklight::Folders::FolderItem do
    association :folder
    association :bookmark
  end

  factory :bookmark do
    sequence(:document) {|n| SolrDocument.new(id: n) }
    user { FactoryGirl.create(:user) }
  end
end
