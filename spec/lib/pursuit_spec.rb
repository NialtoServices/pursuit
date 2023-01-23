# frozen_string_literal: true

RSpec.describe Pursuit do
  describe '::VERSION' do
    subject(:version) { described_class::VERSION }

    it 'is expected to be a semantic version' do
      expect(version).to match(/[0-9]+\.[0-9]+\.[0-9]+/)
    end
  end
end
