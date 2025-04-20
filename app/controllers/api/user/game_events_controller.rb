module Api
  module User
    class GameEventsController < ApplicationController
      before_action :authenticate_user!

      def create
        game_event = GameEvent.find_by(game_event_attributes)
        if game_event.present?
          render json: game_event, status: :ok
        else
          game_event = GameEvent.new(game_event_attributes)
          if game_event.save
            render json: game_event, status: :created
          else
            map_event_type_errors(game_event) if game_event.errors.include?(:event_type)
            render json: { errors: game_event.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      private

      def game_event_attributes
        { user: current_user,
          game_name: event_params[:game_name],
          event_type: event_params[:type]&.downcase,
          occurred_at: event_params[:occurred_at] }
      end

      def event_params
        params.require(:game_event).permit(:game_name, :type, :occurred_at)
      end

      def map_event_type_errors(game_event)
        event_type_errors = game_event.errors.delete(:event_type)
        event_type_errors.each { |message| game_event.errors.add(:type, message) }
      end
    end
  end
end
