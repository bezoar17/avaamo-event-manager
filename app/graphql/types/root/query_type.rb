module Types
  module Root
    class QueryType < Types::Root::BaseObject
      description "The query root of this schema"

      field :user, Types::UserType do
        argument :id, ID, required: true
      end

      field :event, Types::EventType do
        argument :id, ID, required: true
      end

      field :users, [Types::UserType]
      field :events, [Types::EventType]

      # Then provide an implementation:
      def user(id:)
        User.find(id)
      end

      def event(id:)
        User.find(id)
      end

      def users
        User.all
      end

      def events
        Event.all
      end
    end
  end
end