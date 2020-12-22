FactoryBot.define do
  factory :event_user do
    event
    user

    factory :event_user_yes do
      rsvp { :yes }
    end
  end

  trait :rsvp do |val|
    rsvp { val.to_sym }
  end

  trait :role do |val|
    role { val.to_sym }
  end
end