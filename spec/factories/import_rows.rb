# spec/factories/import_rows.rb
FactoryBot.define do
  factory :import_row do
    sequence(:title){|n| "#{Faker::Lorem.word}-#{n}" }
    json_data { "{\"title\": \"#{Faker::Lorem.word}\",\"answer_type\": \"ShortAnswer\",\"prompt\": #{Faker::Lorem.sentences(number: 1)},\"criterion1\": #{Faker::Lorem.sentences(number:1)},\"copy1\": #{Faker::Lorem.sentences(number: 1)},\"points1\": \"1\"}" }
    import_file { }
  end
end
