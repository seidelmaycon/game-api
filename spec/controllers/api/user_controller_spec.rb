require "rails_helper"

describe Api::UserController, type: :controller do
  describe "POST #create" do
    let(:valid_attributes) { attributes_for(:user) }
    let(:invalid_attributes) { { email: "test@example.com" } }

    context "with valid parameters" do
      it "creates a new user and returns created" do
        expect {
          post :create, params: valid_attributes
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(parsed_response["message"]).to eq("User created successfully")
      end
    end

    context "with missing email or password" do
      it "returns a bad request error" do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
        expect(parsed_response["errors"]).to eq([ "Email and password are required" ])
      end
    end

    context "when user email already exists" do
      before { create(:user, email: valid_attributes[:email]) }

      it "returns unprocessable entity error" do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"]).to eq([ "Email has already been taken" ])
      end
    end

    context "when password is invalid" do
      let(:invalid_password_attributes) { attributes_for(:user, password: "short") }

      it "returns unprocessable entity error" do
        post :create, params: invalid_password_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response["errors"]).to eq([ "Password must be at least 8 characters and include at least one letter and one number" ])
      end
    end
  end
end
