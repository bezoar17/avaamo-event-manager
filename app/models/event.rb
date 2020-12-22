class Event < ApplicationRecord
  before_save :adjust_allday_time

  validates :title, :starttime, :presence => true
  validate :validate_start_and_end_times, if: -> { !allday && starttime.present? }

  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users

  # provides a creator fn, but the find_by method below is simpler
  # has_one :main_event_user, -> { where(role: :creator) }, class_name: 'EventUser'
  # has_one :creator, through: :main_event_user, class_name: 'User', source: :user

  scope :completed, lambda { |before: nil|
    where("endtime <= ? ", before || Time.now)
  }

  scope :overlapping_with, lambda { |starttime:, endtime:|
    where(starttime: starttime..endtime).or(where(endtime: starttime..endtime))
  }

  scope :in_date_range, lambda { |start_date:, end_date:|
    within(start_time: start_date.beginning_of_day, end_time: end_date&.end_of_day)
  }

  # not of no_overlap is an easier logic
  scope :within, lambda { |start_time:, end_time:|
    if end_time.present?
      where("(NOT(starttime >= ? OR endtime <= ? ))", end_time, start_time)
    else
      where("(NOT(endtime <= ?))", start_time)
    end
  }

  scope :rsvp_user, lambda { |user_id:, rsvp:|
    joins(:event_users).where(event_users: {user_id: user_id, rsvp: rsvp})
  }

  def completed?
    Time.now > endtime
  end

  def creator
    users.find_by(event_users: {role: :creator})
  end

  def rsvps
    users.where.not(event_users: {rsvp: nil}).select(:id, :username, :rsvp)
  end

  def rsvp(user_id: )
    event_users.find_by(user_id: user_id)
  end

  def time_range
    starttime..endtime
  end

  private

  def adjust_allday_time
    if allday
      self.starttime = starttime.beginning_of_day
      self.endtime = starttime.end_of_day
    end
  end

  def validate_start_and_end_times
    # to allow seeding of events
    # errors.add(:starttime, "Can't create events in past") if starttime < Time.now
    errors.add(:endtime, "Endtime should be present for non all-day event") unless endtime.present?
    errors.add(:endtime, "Endtime should be greater than Starttime") if endtime.present? && endtime < starttime
  end
end
