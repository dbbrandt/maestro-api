# app/controllers/concerns/csv_loader.rb
module CsvLoader

  attr_accessor :csv_filename
  attr_accessor :json_data

  # Load a csv file into an array of hashes with the header row used for keys
  # keys is set to the first row
  def load(file = @csv_filename)
    keys = nil
    csv_data = []
    CSV.foreach(file) do |row|
      keys = row unless keys
      csv_data << Hash[keys.zip(row)]  unless keys == row
    end
    @json_data = csv_data.to_json
  end

end
