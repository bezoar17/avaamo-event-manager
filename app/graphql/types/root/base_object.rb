module Types
  module Root
    class BaseObject < GraphQL::Schema::Object
      field_class Types::Root::BaseField
    end
  end
end
