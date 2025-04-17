require "rails_helper"

RSpec.describe Api::SessionsController, type: :controller do
  describe "POST #create" do
    let!(:user) { create(:user, password: "password123") }

    context "with valid credentials" do
      it "returns a token and status created" do
        post :create, params: { email: user.email, password: "password123" }, as: :json

        expect(response).to have_http_status(:created)
        expect(parsed_response["token"]).to be_present
      end
    end

    context "with invalid email" do
      it "returns unauthorized with error message" do
        post :create, params: { email: "wrong@example.com", password: "password123" }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_response["errors"]).to include("Invalid email or password")
      end
    end

    context "with invalid password" do
      it "returns unauthorized with error message" do
        post :create, params: { email: user.email, password: "wrongpass" }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(parsed_response["errors"]).to include("Invalid email or password")
      end
    end
  end
end
