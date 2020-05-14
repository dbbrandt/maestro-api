class User < ApplicationRecord
  has_secure_password

  has_many :rounds, dependent: :destroy
  has_many :goals, dependent: :destroy
  validates :email, presence: true
end
