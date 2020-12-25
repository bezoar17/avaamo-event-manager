module Mutations
  class CreateUser < Mutations::BaseMutation

    argument :username, String, required: true
    argument :email, String, required: true
    argument :phone, String, required: true

    field :user, Types::UserType, null: false

    def resolve(**inputs)
      {
        user: User.create!(inputs)
      }
    end
  end
end
