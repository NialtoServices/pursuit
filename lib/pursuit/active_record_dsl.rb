# frozen_string_literal: true

module Pursuit
  # Provides a DSL for the `ActiveRecord::Base` class.
  #
  module ActiveRecordDSL
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def has_search(relationships: {}, keyed_attributes: [], unkeyed_attributes: [])
        raise 'The #search method has already been defined.' if respond_to?(:search)

        # The value of `self` is a constant for the current `ActiveRecord::Base` subclass. We'll need to capture this
        # in a custom variable to make it accessible from within the #define_method block.
        klass = self

        define_method(:search) do |query|
          search = Pursuit::ActiveRecordSearch.new(
            klass,
            relationships: relationships,
            keyed_attributes: keyed_attributes,
            unkeyed_attributes: unkeyed_attributes
          )

          search.search(query)
        end
      end
    end
  end
end
