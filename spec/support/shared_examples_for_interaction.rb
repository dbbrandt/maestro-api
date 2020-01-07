require 'spec_helper'

shared_examples "an Interaction class" do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type) }

  # Association test
  # ensure Interactions model has a 1:m relationship with the Content model
  it { should have_many(:contents).dependent(:destroy) }
  # ensure Interactions model belongs to a single goal record
  it { should belong_to(:goal) }

  # Validation tests
  # ensure columns name and type are present before saving

  it 'calculates correct' do
    result = Interaction.new.correct?(1)
    expect(result).to equal true
  end

#  it "should have attribute type" do
#    expect(subject).to have_attribute :type
#  end

  it "should initialize successfully as an instance of the described class" do
    expect(subject).to be_a_kind_of described_class
  end


end