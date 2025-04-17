require "rails_helper"
# require "jwt"

RSpec.describe JsonWebToken do
  let(:payload) { { user_id: 123 } }
  let(:expiration_time) { described_class::SESSION_EXPIRATION_TIME }

  describe ".encode" do
    subject { described_class.encode(payload) }
    it { is_expected.to be_a(String) }
  end

  describe ".decode" do
    let(:token) { described_class.encode(payload) }
    subject { described_class.decode(token) }

    it { is_expected.to be_a(HashWithIndifferentAccess) }
    it { expect(subject[:user_id]).to eq(123) }
    it { expect(subject[:exp]).to be_within(1.second).of(expiration_time.from_now.to_i) }
    it { expect(described_class.decode("invalid.token.here")).to be_nil }

    context "when token is expired" do
      let(:expired_token) { described_class.encode(payload, 1.hour.ago) }
      subject { described_class.decode(expired_token) }

      it { is_expected.to be_nil }
    end
  end
end
