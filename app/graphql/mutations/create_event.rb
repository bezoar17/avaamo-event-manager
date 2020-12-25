module Mutations
  class CreateEvent < Mutations::BaseMutation

    argument :starttime, Types::Scalars::DateTimeType, required: true
    argument :endtime, Types::Scalars::DateTimeType
    argument :allday, Boolean
    argument :title, String
    argument :description, String

    field :event, Types::EventType, null: false

    def resolve(**inputs)
      event = Event.create!(inputs.to_h)
      ::EventUser.create!(event_id: event.id, user_id: context[:current_user].id, role: :creator)

      {
        event: event
      }
    end
  end
end
