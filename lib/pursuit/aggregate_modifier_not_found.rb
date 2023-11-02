# frozen_string_literal: true

module Pursuit
  # Raised when an aggregate modifier cannot be found.
  #
  class AggregateModifierNotFound < QueryError
    # @return [String] The aggregate modifier which does not map to an aggregate function.
    #
    attr_reader :aggregate_modifier

    # Creates a new error instance.
    #
    # @param aggregate_modifier [Symbol] The aggregate modifier which does not map to an aggregate function.
    #
    def initialize(aggregate_modifier)
      @aggregate_modifier = aggregate_modifier
      super("#{aggregate_modifier} is not a valid aggregate modifier")
    end
  end
end
