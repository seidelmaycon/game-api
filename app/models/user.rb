class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validate :password_complexity

  has_many :game_events, dependent: :destroy

  def total_games_played
    game_events.completed.count
  end

  private

  def password_complexity
    return if password.blank?

    unless password.length >= 8 && password =~ /[a-zA-Z]/ && password =~ /\d/
      errors.add(:password, "must be at least 8 characters and include at least one letter and one number")
    end
  end
end
