class User < ApplicationRecord
  has_secure_password

  has_many :rounds
  validates :email, presence: true
end
