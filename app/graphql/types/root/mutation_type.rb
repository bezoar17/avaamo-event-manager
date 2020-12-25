module Types
  module Root
    class MutationType < Types::Root::BaseObject
      description "The mutation root for this schema"

      field :create_user, mutation: Mutations::CreateUser
      field :create_event, mutation: Mutations::CreateEvent

      field :add_users_to_event, mutation: Mutations::AddUsersToEvent
      field :rsvp_to_event, mutation: Mutations::RsvpToEvent
    end
  end
end
