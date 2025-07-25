class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :stats, :subscription_status

  def stats
    {
      total_games_played: object.total_games_played
    }
  end

  def subscription_status
    instance_options.dig(:context, :subscription_status)
  end
end
