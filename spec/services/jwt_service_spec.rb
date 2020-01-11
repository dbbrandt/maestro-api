# require 'rails_helper'

describe JwtService do
  subject { described_class }

  let(:payload) { { 'one' => 'two' } }
  let(:token) { 'eyJhbGciOiJIUzI1NiJ9.eyJvbmUiOiJ0d28ifQ.3wMbtCaxKwu1PSiugNs-mgDsY7sE41glrPF0W9Nbu24' }

  describe '.encode' do
    it { expect(subject.encode(payload)).to eq(token) }
  end

  describe '.decode' do
    it { expect(subject.decode(token)).to eq(payload) }
  end
end
