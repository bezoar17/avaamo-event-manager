module Mutations
  class AddUsersToEvent < Mutations::BaseMutation

    argument :event_id, ID, required: true
    argument :ids, [ID], required: true

    field :success, Boolean, null: false

    def resolve(**inputs)
      event = Event.find(inputs[:event_id])

      user_ids = inputs[:ids] - EventUser.where(event_id: event.id).pluck(:user_id)
      entries = user_ids.map { |user_id| {event_id: event.id, user_id: user_id, created_at: Time.now, updated_at: Time.now} }
      EventUser.insert_all! entries

      {
        success: true
      }
    end
  end
end
