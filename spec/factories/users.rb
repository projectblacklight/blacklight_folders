FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password '12345678'

    factory :guest_user do
      guest true
    end
  end
end
