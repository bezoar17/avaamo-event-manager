module Types
  module Root
    class BaseField < GraphQL::Schema::Field
      argument_class Types::Root::BaseArgument

      # https://graphql-ruby.org/fields/introduction
      # null: true means that the field may return nil
      # Add `null: true` and `camelize: false` which provide default values
      # in case the caller doesn't pass anything for those arguments.
      # **kwargs is a catch-all that will get everything else
      def initialize(*args, null: true, camelize: false, **kwargs, &block)
        # Then, call super _without_ any args, where Ruby will take
        # _all_ the args originally passed to this method and pass it to the super method.
        super
      end
    end
  end
end

