FactoryGirl.define do

  factory :folder, aliases: [:private_folder], class: Blacklight::Folders::Folder do
    sequence(:name) { |n| "Folder #{n}" }
    user { FactoryGirl.create(:user) }
    visibility { Blacklight::Folders::Folder::PRIVATE }
  end

  factory :public_folder, parent: :folder do
    visibility { Blacklight::Folders::Folder::PUBLIC }
  end

end
