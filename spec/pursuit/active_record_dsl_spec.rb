# frozen_string_literal: true

RSpec.describe Pursuit::ActiveRecordDSL do
  subject(:product) { Product.new }

  it { is_expected.to respond_to(:search) }
end
