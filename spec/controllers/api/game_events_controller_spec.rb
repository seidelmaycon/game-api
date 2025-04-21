require 'rails_helper'

RSpec.describe Api::User::GameEventsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { { game_name: "Brevity", type: "completed", occurred_at: "2025-01-01T00:00:00.000Z" } }
  let(:invalid_attributes) { { game_name: "Brevity", type: "started", occurred_at: "2025-01-01T00:00:00.000Z" } }

  describe 'POST #create' do
    context "when authenticated" do
      before { set_auth_header_for(user) }

      context "with valid parameters" do
        it "creates a new game event and returns created" do
          expect {
            post :create, params: { game_event: valid_attributes }, as: :json
          }.to change(GameEvent, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(parsed_response["game_event"]).to eq({
            "id" => GameEvent.last.id,
            "game_name" => "Brevity",
            "type" => "COMPLETED",
            "occurred_at" => "2025-01-01T00:00:00.000Z"
          })
        end
      end

      context "when GameEvent already exists" do
        let!(:game_event) { GameEvent.create!(user: user, game_name: valid_attributes[:game_name], event_type: valid_attributes[:type], occurred_at: valid_attributes[:occurred_at]) }

        it "returns ok" do
          expect {
            post :create, params: { game_event: valid_attributes }, as: :json
          }.to change(GameEvent, :count).by(0)

          expect(response).to have_http_status(:ok)
          expect(parsed_response["game_event"]).to eq({
            "id" => game_event.id,
            "game_name" => "Brevity",
            "type" => "COMPLETED",
            "occurred_at" => "2025-01-01T00:00:00.000Z"
          })
        end
      end

      context "with invalid parameters" do
        it "returns unprocessable entity" do
          post :create, params: { game_event: invalid_attributes }, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(parsed_response["errors"]).to eq([ "Type is not included in the list" ])
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 unauthorized response" do
        post :create, params: { game_event: valid_attributes }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
