# frozen_string_literal: true

module Pursuit
  module DSL
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def searchable(&block)
        if respond_to?(:search_options) || respond_to?(:search)
          raise "#{self} already has #search and #search_options defined."
        end

        options = SearchOptions.new(self, &block)

        define_singleton_method(:search_options) do
          options
        end

        define_singleton_method(:search) do |query|
          search = Pursuit::Search.new(options)
          search.perform(query)
        end
      end
    end
  end
end
