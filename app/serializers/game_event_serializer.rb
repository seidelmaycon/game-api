class GameEventSerializer < ActiveModel::Serializer
  attributes :id, :game_name, :type, :occurred_at

  def type
    object.event_type.upcase
  end
end
