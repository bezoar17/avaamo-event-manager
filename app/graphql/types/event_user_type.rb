module Types
  class EventUserType < Types::Root::BaseObject
    description "Event User Entity"

    field :id, ID, null: false
    field :user, Types::UserType, null: false
    field :event, Types::EventType, null: false
    field :rsvp, RsvpEnumType, null: false
    field :role, String, null: false

    def event
      RecordLoader.for(Event).load(object.event_id)
    end

    def user
      RecordLoader.for(User).load(object.user_id)
    end
  end
end
