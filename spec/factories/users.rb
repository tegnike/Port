FactoryBot.define do
  factory :user do
    username { Faker::Name.name }
    email { Faker::Internet.email }
    engineer { true }
    password { "password" }
    password_confirmation { "password" }
    # confirmed_at { Time.zone.now }
  end
end
