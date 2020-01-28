class Content < ApplicationRecord
  PROMPT = 'Prompt'
  CRITERION = 'Criterion'

  TYPES = [PROMPT, CRITERION]

  belongs_to :interaction, required: true
  default_scope { order(:title) }

  validates_presence_of :title
  validates_inclusion_of :content_type, in: TYPES

  validate :validate_required

  def validate_required
    if content_type == PROMPT && stimulus_url.blank? && copy.blank?
      errors.add :base, "Prompt must have a stimulus image or copy."
    elsif content_type == CRITERION && descriptor.blank?
      errors.add :base, "Criterion must have a descriptor (correct answer)."
    end
  end
end
