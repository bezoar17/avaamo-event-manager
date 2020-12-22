require 'rails_helper'

RSpec.describe EventUser, type: :model do
  # association tests
  it { should belong_to(:event) }
  it { should belong_to(:user) }

  # validation tests
end
