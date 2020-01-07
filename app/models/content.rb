class Content < ApplicationRecord
  PROMPT = 'Prompt'
  CRITERION = 'Criterion'

  TYPES = [PROMPT, CRITERION]

  belongs_to :interaction, required: true
  default_scope { order(:title) }

  validates_presence_of :title
  validates_inclusion_of :content_type, in: TYPES

  validates_presence_of :stimulus_url, unless: :copy?
end
