FactoryBot.define do
  factory :user do
    sequence(:email, 1000) { |n| "test#{n}@example.com" }
    password { "password123" }
  end
end
