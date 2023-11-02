# frozen_string_literal: true

module Pursuit
  # Raised when an attribute cannot be found.
  #
  class AttributeNotFound < QueryError
    # @return [Symbol] The name of the attribute which could not be found.
    #
    attr_reader :attribute

    # Creates a new error instance.
    #
    # @param attribute [Symbol] The name of the attribute which could not be found.
    #
    def initialize(attribute)
      @attribute = attribute
      super("'#{attribute}' is not a valid attribute")
    end
  end
end
