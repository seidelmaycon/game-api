require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'password complexity validation' do
    context "when password is less than 8 characters" do
      it 'is invalid' do
        user = build(:user, password: 'abc123')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must be at least 8 characters and include at least one letter and one number')
      end
    end

    context "when password does not contain a letter" do
      it 'is invalid' do
        user = build(:user, password: '12345678')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must be at least 8 characters and include at least one letter and one number')
      end
    end

    context "when password does not contain a number" do
      it 'is invalid' do
        user = build(:user, password: 'abcdefgh')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must be at least 8 characters and include at least one letter and one number')
      end
    end

    context "when password contains at least 8 characters, one letter, and one number" do
      it 'is valid' do
        user = build(:user, password: 'abc12345')
        expect(user).to be_valid
      end
    end
  end
end
