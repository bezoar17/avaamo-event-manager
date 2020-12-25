module Types
  class UserType < Types::Root::BaseObject
    description "User Entity"

    field :id, ID, null: false
    field :username, String, null: false
    field :email, String, null: false
    field :phone, String, null: false
    field :event_users, [Types::EventUserType]

    field :events, [Types::EventType] do
      argument :start_date, Types::Scalars::DateTimeType
      argument :end_date, Types::Scalars::DateTimeType
    end

    field :availability, [Types::AvailabilityType], null: false  do
      argument :start_date, Types::Scalars::DateTimeType, required: true
      argument :end_date, Types::Scalars::DateTimeType, required: true
      argument :slot_size, Int
    end

    def event_users
      RecordLoader.for(EventUser, group_key: :user_id).load(object.id)
    end
  end
end
