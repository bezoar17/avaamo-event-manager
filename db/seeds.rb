# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# define the order of seed below

seed_order = %w(users events)

seed_files = seed_order.map { |file_name| Rails.root.join('db', 'seeds', "#{file_name}.csv") };

seed_files.each do |seed|
  start_time = Time.now
  documents = YAML.load_file(seed)
  klass = File.basename(seed, '.yml').classify.constantize
  klass.transaction do
    documents.each {|doc| klass.create(doc)}
  end
  puts "#{klass.count} #{klass.to_s.pluralize} seeded into db (#{(Time.now - start_time).round(2)} sec)"
end
