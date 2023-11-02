# frozen_string_literal: true

module Pursuit
  # Raised when an aggregate modifier is used in a query, but aggregate modifiers are not available.
  #
  class AggregateModifiersNotAvailable < QueryError
    # Creates a new error instance.
    #
    def initialize
      super('Aggregate modifiers cannot be used in this query')
    end
  end
end
