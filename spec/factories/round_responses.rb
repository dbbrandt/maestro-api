# spec/factories/interactions.rb
FactoryBot.define do
  factory :round_response do
    #answer { Faker::Lorem.word }
    score { 1 }
    is_correct { true }
    review_is_correct { true }
    descriptor { Faker::Lorem.word }
#    round { }
    interaction
  end

  trait :incorrect do
    score { 0 }
    is_correct { false }
    review_is_correct { false }
  end

  trait :review_correct do
    review_is_correct { true }
  end

  factory :incorrect_response, traits: [:incorrect]
  factory :incorrect_review_correct_response, traits: [:incorrect, :review_correct]
end
