class User < ApplicationRecord
  validates :email, :username, :phone, :presence => true, :uniqueness => true

  has_many :event_users, dependent: :destroy
  has_many :events, -> { order(:starttime) },  through: :event_users

  def attending_events
    events.where(event_users: {rsvp: :yes})
  end

  def rsvps
    events.where.not(event_users: {rsvp: nil}).select(:id, :title, :description, :starttime, :endtime, :rsvp)
  end

  def availability(start_date:, end_date:, slot_size: AppConstant::Defaults::DEFAULT_INTERVAL)
    relevant_events = self.attending_events.in_date_range(start_date: start_date, end_date: end_date)

    intervals = ::Util::Time.time_slots(start_date.beginning_of_day, end_date.end_of_day, slot_size.seconds)
    busy_indices = ::Util::Time.overlapping_slot_indices(intervals, relevant_events.map(&:time_range)).to_set

    intervals.map.with_index do |interval, idx|
      {
        time_range: { start: interval.first, end: interval.last },
        available: !busy_indices.include?(idx)
      }
    end
  end
end

