class GameEvent < ApplicationRecord
  belongs_to :user

  enum :event_type, { completed: 0 }, validate: true

  validates :game_name, presence: true
  validates :occurred_at, presence: true, comparison: { less_than: -> { Time.current } }
  validates :user_id, presence: true
  validates :event_type, presence: true

  validates :occurred_at, uniqueness: { scope: [ :user_id, :game_name, :event_type ], message: "event already ingested for this user/game/type/occurred_at" }
end
