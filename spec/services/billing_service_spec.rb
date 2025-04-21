require "rails_helper"

RSpec.describe BillingService do
  let(:base_url) { "https://billing-api.example.com" }
  let(:api_key) { "test-api-key" }
  subject { described_class.new(base_url: base_url, api_key: api_key) }
  let(:user_id) { 1 }

  describe "#get_subscription_status" do
    before do
      stub_request(:get, "#{base_url}/users/#{user_id}/billing")
        .with(
          headers: {
            "Authorization" => api_key,
            "Content-Type" => "application/json"
          }
        )
        .to_return(status: status_code, body: response_body.to_json)
    end

    context "when the API call is successful" do
      let(:status_code) { 200 }
      let(:response_body) { { "subscription_status" => "active" } }

      context "when subscription_status is valid" do
        it "returns the subscription status and success flag" do
          result = subject.get_subscription_status(user_id)

          expect(result).to eq(BillingService::Result.new("active"))
        end
      end

      context "when subscription_status is invalid" do
        let(:status_code) { 200 }
        let(:response_body) { { "subscription_status" => "cancelled" } }

        it "returns the fallback status and failure flag" do
          result = subject.get_subscription_status(user_id)

          expect(result).to eq(BillingService::Result.new("unknown"))
        end
      end

      context "when subscription_status is missing" do
        let(:status_code) { 200 }
        let(:response_body) { { "other_data" => "value" } }

        it "returns the fallback status and failure flag" do
          result = subject.get_subscription_status(user_id)

          expect(result).to eq(BillingService::Result.new("unknown"))
        end
      end
    end

    context "when the API returns 404" do
      let(:status_code) { 404 }
      let(:response_body) { { "error" => "User not found" } }

      it "returns the fallback status and failure flag" do
        result = subject.get_subscription_status(user_id)

        expect(result).to eq(BillingService::Result.new("not_found"))
      end
    end

    context "when the API call fails" do
      let(:status_code) { 500 }
      let(:response_body) { { "error" => "Service temporarily unavailable" } }

      it "returns the fallback status and failure flag" do
        result = subject.get_subscription_status(user_id)

        expect(result).to eq(BillingService::Result.new("unknown"))
      end
    end

    context "when a Faraday error occurs" do
      let(:status_code) { 200 }
      let(:response_body) { { "subscription_status" => "active" } }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::TimeoutError)
      end

      it "rescues the error and returns the fallback status and failure flag" do
        result = subject.get_subscription_status(user_id)

        expect(result).to eq(BillingService::Result.new("unknown"))
      end
    end

    context "when a JSON parsing error occurs" do
      let(:status_code) { 200 }
      let(:response_body) { "invalid json" }

      before do
        stub_request(:get, "#{base_url}/users/#{user_id}/billing")
          .to_return(status: status_code, body: response_body)
      end

      it "rescues the error and returns the fallback status and failure flag" do
        result = subject.get_subscription_status(user_id)

        expect(result).to eq(BillingService::Result.new("unknown"))
      end
    end
  end

  describe "initialization" do
    context "when base_url and api_key are provided" do
      it "uses the provided values" do
        expect(subject.base_url).to eq("https://billing-api.example.com")
        expect(subject.api_key).to eq("test-api-key")
      end
    end

    context "when base_url and api_key are not provided" do
      before do
        allow(Rails.application.credentials).to receive(:billing_api)
          .and_return({ base_url: "default-url", key: "default-key" })
      end

      it "uses the values from Rails credentials" do
        service = described_class.new
        expect(service.base_url).to eq("default-url")
        expect(service.api_key).to eq("default-key")
      end
    end
  end
end
