class EventUser < ApplicationRecord

  enum role: {
    creator: "creator",
    invitee: "invitee"
  }

  enum rsvp: {
    yes: "yes",
    no: "no",
    maybe: "maybe"
  }

  belongs_to :event
  belongs_to :user

  scope :overlapping_events_with, lambda { |starttime:, endtime:|
    joins(:event).where(events: {starttime: starttime..endtime}).or(where(events: {endtime: starttime..endtime}))
  }

  after_commit      :update_overlapping_events, on: [:create, :update]

  def update_overlapping_events
    # if the rsvp update is yes, update other overlapping yes rsvps for the user
    if yes? # as rsvp is an enum, yes? is shorthand for rsvp.to_sym == :yes
      overlapping_rsvps = user.event_users.yes.overlapping_events_with(starttime: event.starttime, endtime: event.endtime)
      overlapping_rsvps -=[self]

      overlapping_rsvps.each { |entry| entry.update!(rsvp: :no) }
    end
  end
end
