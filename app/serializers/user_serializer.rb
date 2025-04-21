class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :stats

  def stats
    {
      total_games_played: object.game_events.count
    }
  end
end
