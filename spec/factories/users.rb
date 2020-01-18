# spec/factories/goals.rb
FactoryBot.define do
  encryptor = JwtService
  factory :user do
    email { Faker::Lorem.word }
    name { Faker::Lorem.word }
    password_digest { encryptor.encode(Faker::Lorem.word) }
  end
end
