class Round < ApplicationRecord
  belongs_to :goal
  belongs_to :user

  has_many :round_responses, dependent: :destroy
end
