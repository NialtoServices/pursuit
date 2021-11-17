# frozen_string_literal: true

module Pursuit
  class Railtie < Rails::Railtie
    initializer 'pursuit.active_record.inject_dsl' do
      ActiveSupport.on_load(:active_record) do
        require 'pursuit/active_record_dsl'

        ActiveRecord::Base.include(Pursuit::ActiveRecordDSL)
      end
    end
  end
end
