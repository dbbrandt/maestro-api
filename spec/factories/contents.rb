# spec/factories/contents.rb
FactoryGirl.define do
  factory :content do
    title { Faker::Lorem.word }
    content_type { "Prompt" }
    description { Faker::Lorem.word }
    copy { Faker::Lorem.word }
    interaction { }
  end

  trait :criterion do
    content_type { "Criterion" }
    score 1
    descriptor { Faker::Lorem.word }
  end
end
