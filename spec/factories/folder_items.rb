FactoryGirl.define do
  factory :folder_item, aliases: [:item], class: Blacklight::Folders::FolderItem do
    association :folder
    sequence(:position) { |n| n }
    document_id 'id:123'
    document_type 'SolrDocument'
  end
end
