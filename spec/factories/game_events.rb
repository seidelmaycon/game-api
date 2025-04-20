FactoryBot.define do
  factory :game_event do
    association :user
    game_name { "Brevity" }
    event_type { "completed" }
    occurred_at { rand(1..365).days.ago }
  end
end
