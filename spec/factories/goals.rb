# spec/factories/goals.rb
FactoryGirl.define do
  factory :goal do
    title { Faker::Lorem.word }
  end
end