class ImportRow < ApplicationRecord
  include ActiveModel::Validations

  validates_uniqueness_of :title, scope: :import_file_id
  validates_with ImportRowValidator

  # order by id for ease of review in sequential import
  default_scope { order('id') }

  belongs_to :import_file, required: true
  has_one :interaction

  def json
    @json ||= JSON.parse(json_data)
  end
end
