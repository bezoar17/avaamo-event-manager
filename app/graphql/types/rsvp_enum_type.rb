module Types
  class RsvpEnumType < GraphQL::Schema::Enum
    description "Rsvp values for Event User"

    value("yes")
    value("no")
    value("maybe")
  end
end
