require "rails_helper"

RSpec.describe GameEvent, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:game_event) }

    it { should validate_presence_of(:game_name) }
    it { should validate_presence_of(:occurred_at) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:event_type) }

    it "validates that occurred_at is in the past" do
      game_event = build(:game_event, occurred_at: Time.current + 1.day)

      expect(game_event).not_to be_valid
      expect(game_event.errors[:occurred_at].first).to start_with("must be less than")
    end

    context "uniqueness validations" do
      let(:user) { create(:user) }
      let(:occurred_at) { 1.day.ago }
      let(:game_name) { "Brevity" }
      let(:event_type) { :completed }

      before { create(:game_event, user: user, game_name: game_name, event_type: event_type, occurred_at: occurred_at) }

      it "user/game/type/occurred_at must be unique" do
        duplicate_event = build(:game_event, user: user, game_name: game_name, event_type: event_type, occurred_at: occurred_at)

        expect(duplicate_event).not_to be_valid
        expect(duplicate_event.errors[:occurred_at].first).to start_with("event already ingested for this user/game/type/occurred_at")
      end
    end
  end

  describe "enums" do
    it { should define_enum_for(:event_type).with_values(completed: 0) }
  end
end
