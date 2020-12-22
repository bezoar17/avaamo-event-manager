FactoryBot.define do
  factory :event do
    title { Faker::Lorem.sentence(word_count: 2) }
    description { Faker::Lorem.sentence }
    starttime { Faker::Time.forward(days: 1) }
    endtime { Faker::Time.between(from: starttime, to: (starttime + 1.day)) }
  end

  trait :allday do
    allday { true }
  end
end