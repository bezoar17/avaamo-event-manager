# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# define the order of seed below

# seed_order = %w(users events)
require 'csv'

# helper functions
def insert_in_bulk(klass, records)
  now = Time.now
  records = records.map { |e| e.merge(created_at: now, updated_at: now)  }
  begin
    klass.insert_all! records
  rescue StandardError => ex
    puts ex.full_message(highlight: true, order: :bottom)
  end
end

seed_order = %w(users)
seed_files = seed_order.map { |file_name| Rails.root.join('db', 'seeds', "#{file_name}.csv") };

# assumes csv has all required columns, except timestamps, which will be added by the function
seed_files.each do |seed_file|
  start_time = Time.now
  klass = File.basename(seed_file, '.csv').classify.constantize

  records = []
  CSV.foreach(seed_file, headers: true) { |row| records << row.to_h }
  insert_in_bulk(klass, records)
end

# CUSTOM SEED functions below
def seed_events_from_csv(seed_file)
  # seed rsvps
  username_h = User.pluck(:username,:id).to_h
  event_h = {}
  all_rsvp_values = []

  # seed each event, and collect it's rsvps
  CSV.foreach(seed_file, headers: true) do |row|
    allday = ActiveModel::Type::Boolean.new.cast(row["allday"])

    next if !allday && (DateTime.parse(row["endtime"]) < DateTime.parse(row["starttime"]))

    event = Event.create!(row.to_h.merge(allday: allday).except(AppConstant::Defaults::USER_RSVP_COLUMN))
    event_h[event.id] = event

    all_rsvp_values += row[AppConstant::Defaults::USER_RSVP_COLUMN].to_s.split(AppConstant::Defaults::RSVP_USER_SEPARATOR).map do |val|
      username, rsvp = val.split(AppConstant::Defaults::RSVP_VALUE_SEPARATOR)
      { event_id: event.id, user_id: username_h[username], rsvp: rsvp }
    end
  end

  no_maybe_rsvp_values, yes_rsvp_values = all_rsvp_values.partition { |e| e[:rsvp] != "yes" }
  all_rsvp_values = no_maybe_rsvp_values + update_yes_rsvps(yes_rsvp_values, event_h)

  # seed rsvps in bulk
  insert_in_bulk(EventUser, all_rsvp_values)
end

# takes all yes rsvps for a user and ensures
# max amount of user rsvps are yes for non-overlapping events, returns the same format
def update_yes_rsvps(yes_rsvp_values, event_h)
  yes_rsvp_values.group_by{|e| e[:user_id] }.transform_values do |rsvps|
    # process the rsvps for a user

    sorted_rsvps = rsvps.map do |entry|
      entry[:event] = event_h[entry[:event_id]]
      entry
    end.sort_by {|e| e[:event].endtime}


    previous_yes_endtime = sorted_rsvps.first[:event].endtime
    sorted_rsvps[1..-1].each do |entry|
      if entry[:event].starttime < previous_yes_endtime
        # current event overlaps with previous yes rsvp
        entry[:rsvp] = :no
      else
        previous_yes_endtime = entry[:event].endtime
      end
    end

    sorted_rsvps.map { |e| e.except(:event) }
  end.values.flatten # revert the grouping and return
end

seed_events_from_csv('db/seeds/events.csv')
