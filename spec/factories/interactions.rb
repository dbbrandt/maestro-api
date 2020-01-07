# spec/factories/interactions.rb
FactoryBot.define do
  factory :interaction do
    title { Faker::Lorem.word }
    answer_type { 'ShortAnswer' }
    goal { }
  end
end
