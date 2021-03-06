class Goal < ApplicationRecord
  validates_presence_of :title, :user_id
  default_scope { order(:title)}

  has_many :interactions, dependent: :destroy
  has_many :import_files, dependent: :destroy
  has_many :contents, through: :interactions
  has_many :rounds
  has_many :round_responses, through: :rounds
  belongs_to :user
end
