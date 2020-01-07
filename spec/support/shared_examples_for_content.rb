require 'spec_helper'

shared_examples "a Content class" do

  # Association test
  # ensure Interactions model belongs to a single goal record
  it { should belong_to(:interactions) }

  # Validation tests
  # ensure columns name and type are present before saving
  it { should validate_presence_of(:type) }

  # Content should have at least copy or image_url present. Both are also permitted.
  context "when copy is nil" do
    let(:copy) { nil }
    it { should validate_presence_of(:image_url) }
  end

  context "when image_url is nil" do
    let(:image_url) { nil }
    it { should validate_presence_of(:copy) }
  end

  it "should initialize successfully as an instance of the described class" do
    expect(subject).to be_a_kind_of described_class
  end
end
