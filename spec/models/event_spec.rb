require 'rails_helper'

RSpec.describe Event, type: :model do
  # Validation test
  it { should validate_presence_of(:starttime) }
  it { should validate_presence_of(:title) }

  context 'when not allday event' do
    subject { build(:event, allday: false) }
    it 'validates endttime > starttime' do
      t = subject.endtime > subject.starttime
      expect(t).to eq(true)
    end
  end

  context 'when an allday event' do
    subject { build(:event, :allday) }
    it 'validates endttime > starttime' do
      t = subject.endtime > subject.starttime
      expect(t).to eq(true)
    end
  end

  it { should have_many(:event_users).dependent(:destroy) }
end
