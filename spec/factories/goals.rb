# spec/factories/goals.rb
FactoryBot.define do
  factory :goal do
    title { Faker::Lorem.word }
  end
end