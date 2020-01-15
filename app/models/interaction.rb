class Interaction < ApplicationRecord
  # For Levenshtein fuzzy match
  include Amatch

  SHORT_ANSWER = 'ShortAnswer'
  MULTIPLE_CHOICE = 'MultipleChoice'
  TYPES = [SHORT_ANSWER, MULTIPLE_CHOICE]
  CORRECT_THRESHOLD = 0.85
  OVERRIDE_THRESHOLD = 0.95

  #acts_as_list add_new_at: :top
  default_scope { order('updated_at DESC') }

  scope :short_answer, -> { where(answer_type: 'ShortAnswer')}
  scope :multiple_choice, -> { where(answer_type: 'MultipleChoice')}

  validates_presence_of :title
  validates_inclusion_of :answer_type, in: TYPES

  belongs_to :goal, required: true
  has_many :contents, :dependent => :destroy

  # Return the title if copy is not available
  def copy
    super || title
  end

  def stimulus_url
    return unless prompt
    prompt.stimulus_url || ""
  end

  def prompt
    contents.where(content_type: Content::PROMPT).first
  end

  def criterion
    contents.where(content_type: Content::CRITERION)
  end

  def correct_answer
    return @correct_answer if @correct_answer
    answer = criterion.where(score: 1).first
    @correct_answer ||= answer.descriptor if answer
  end

  def check_answer(answer)
    m = Levenshtein.new(correct_answer.downcase)
    match = m.match(answer.downcase)
    length = (correct_answer+answer).length
    score = (length - match).to_f/length
    check = score >= CORRECT_THRESHOLD
    [check, score.round(3)]
  end

  def score_override?(score)
    score >= OVERRIDE_THRESHOLD
  end
end
