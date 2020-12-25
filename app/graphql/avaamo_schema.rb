class AvaamoSchema < GraphQL::Schema
  query Types::Root::QueryType
  mutation Types::Root::MutationType

  use GraphQL::Batch
end
