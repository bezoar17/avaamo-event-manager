require 'rails_helper'

RSpec.describe User, type: :model do
  # Validation tests
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:phone) }

  # https://stackoverflow.com/questions/27046691/cant-get-uniqueness-validation-test-pass-with-shoulda-matcher/27049308
  describe "uniqueness" do
    subject { FactoryBot.build(:user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_uniqueness_of(:phone).case_insensitive }
  end

  # Association test
  it { should have_many(:event_users).dependent(:destroy) }
end
