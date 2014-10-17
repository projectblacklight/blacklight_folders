FactoryGirl.define do

  factory :folder, class: Blacklight::Folders::Folder do
    sequence(:name) { |n| "Folder #{n}" }
    user { FactoryGirl.create(:user) }
  end 

end
