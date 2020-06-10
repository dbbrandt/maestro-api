# spec/factories/goals.rb
FactoryBot.define do
  encryptor = JwtService
  factory :user do
    sequence(:email){|n| "user#{n}@factory.com" }
    name { Faker::Lorem.word }
    password_digest { encryptor.encode(Faker::Lorem.word) }

    factory :admin_user do
      admin { true }
    end
  end

end
