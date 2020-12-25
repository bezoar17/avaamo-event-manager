module Types
  module Scalars
    class DateTimeType < GraphQL::Schema::Scalar
      description "DateTime type"

      def self.coerce_input(value, _ctx)
        value.is_a?(String) ? DateTime.parse(value) : nil
      end
    end
  end
end