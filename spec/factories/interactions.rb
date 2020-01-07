# spec/factories/interactions.rb
FactoryGirl.define do
  factory :interaction do
    title { Faker::Lorem.word }
    answer_type { 'ShortAnswer' }
    goal { }
  end
end