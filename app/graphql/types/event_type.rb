module Types
  class EventType < Types::Root::BaseObject
    description "Event Entity"

    field :id, ID, null: false
    field :title, String,  null: false
    field :description, String
    field :starttime, Scalars::DateTimeType, null: false
    field :endtime, Scalars::DateTimeType, null: false
    field :allday, Boolean, null: false
    field :event_users, [Types::EventUserType]
    field :invitees, [Types::UserType], method: :users
    field :rsvps, [Types::EventUserType]

    def event_users
      RecordLoader.for(EventUser, group_key: :event_id).load(object.id)
    end
  end
end
