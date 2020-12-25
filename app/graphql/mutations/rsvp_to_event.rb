module Mutations
  class RsvpToEvent < Mutations::BaseMutation

    argument :event_id, ID, required: true
    argument :rsvp, Types::RsvpEnumType, required: true

    field :success, Boolean, null: false

    def resolve(**inputs)
      event = Event.find(inputs[:event_id])
      event_user = event.rsvp(user_id: context[:current_user].id)
      event_user.update!(rsvp: params[:value])

      {
        success: true
      }
    end
  end
end