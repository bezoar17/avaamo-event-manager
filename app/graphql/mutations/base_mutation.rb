module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    field_class Types::Root::BaseField
    argument_class Types::Root::BaseArgument
  end
end
