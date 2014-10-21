FactoryGirl.define do
  factory :folder_item, aliases: [:item], class: Blacklight::Folders::FolderItem do
    association :folder
    document_id 'id:123'
  end
end
