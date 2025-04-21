require "rails_helper"

describe Api::UserController, type: :controller do
  describe "GET #show" do
    context "when authenticated" do
      let(:user) { create(:user) }
      let!(:game_events) { create_list(:game_event, 5, user: user) }
      let!(:another_user_game_events) { create_list(:game_event, 3, user: create(:user)) }
      before { set_auth_header_for(user) }

      it "returns a 200 response with the current user" do
        get :show, as: :json

        expect(response).to have_http_status(:ok)
        expect(parsed_response).to eq({
          "user" => {
            "id" => user.id,
            "email" => user.email,
            "stats" => {
              "total_games_played" => 5
            }
          }
        })
      end
    end

    context "when not authenticated" do
      it "returns a 401 unauthorized response" do
        get :show, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { attributes_for(:user) }
    let(:invalid_attributes) { { email: "test@example.com" } }

    context "with valid parameters" do
      it "creates a new user and returns created" do
        expect {
          post :create, params: valid_attributes, as: :json
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(parsed_response["message"]).to eq("User created successfully")
      end
    end

    context "with missing email or password" do
      it "returns a bad request error" do
        post :create, params: invalid_attributes, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(parsed_response["errors"]).to eq([ "Email and password are required" ])
      end
    end

    context "when user email already exists" do
      before { create(:user, email: valid_attributes[:email]) }

      it "returns unprocessable entity error" do
        post :create, params: valid_attributes, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"]).to eq([ "Email has already been taken" ])
      end
    end

    context "when password is invalid" do
      let(:invalid_password_attributes) { attributes_for(:user, password: "short") }

      it "returns unprocessable entity error" do
        post :create, params: invalid_password_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"]).to eq([ "Password must be at least 8 characters and include at least one letter and one number" ])
      end
    end
  end
end
