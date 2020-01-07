class Goal < ApplicationRecord
  validates_presence_of :title
  default_scope { order(:title)}

  has_many :interactions, :dependent => :destroy
  has_many :import_files, :dependent => :destroy
  has_many :contents, through: :interactions
end
