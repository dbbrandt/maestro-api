# spec/factories/import_files.rb
FactoryGirl.define do
  factory :import_file do
    title { Faker::Lorem.word }
    json_data { "[{\"title\": \"#{Faker::Lorem.word}\",\"answer_type\": \"ShortAnswer\",\"prompt\": \"#{Faker::Lorem.word}\",\"criterion1\": \"#{Faker::Lorem.word}\",\"points1\": \"1\"}]" }
    goal { }
  end
end