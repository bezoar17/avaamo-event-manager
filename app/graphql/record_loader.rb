require "graphql/batch"

class RecordLoader < GraphQL::Batch::Loader
  def initialize(model, group_key: nil)
    @model = model
    @group_key = group_key
  end

  def perform(keys)
    query(keys).each { |record| fulfill(record.id, (record.try(:result) || record )) }
    keys.each { |key| fulfill(key, nil) unless fulfilled?(key) }
  end

  private

  def query(keys)
    return @model.where(id: keys) unless @group_key.present?
    @model.where({@group_key => keys}).group_by(&@group_key).map { |k,v| OpenStruct.new(id: k, result: v) }
  end
end