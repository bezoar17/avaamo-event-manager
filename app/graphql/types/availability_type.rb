module Types
  class AvailabilityType < Types::Root::BaseObject
    description "Availability array for a User"

    field :available, Boolean, null: false
    field :start_time, Scalars::DateTimeType, null: false
    field :end_time, Scalars::DateTimeType, null: false

    def start_time
      object.dig(:time_range, :start)
    end

     def end_time
      object.dig(:time_range, :end)
    end
  end
end
