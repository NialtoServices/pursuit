# frozen_string_literal: true

module Pursuit
  # Raised when an attribute that must be used with an aggregate modifier is used without one.
  #
  class AggregateModifierRequired < QueryError
    # @return [Symbol] The name of the attribute which must be used with an aggregate modifier.
    #
    attr_reader :attribute

    # Creates a new error instance.
    #
    # @param attribute [Symbol] The name of the attribute which must be used with an aggregate modifier.
    #
    def initialize(attribute)
      @attribute = attribute
      super("'#{attribute}' must be used with an aggregate modifier")
    end
  end
end
