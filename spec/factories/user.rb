FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.unique.phone_number }
  end
end