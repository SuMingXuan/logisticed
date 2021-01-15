require "logisticed/version"
require_relative "logisticed/logistic"
require_relative "logisticed/sweeper"

module Logisticed
  class Migration < Rails::Engine; end
  class Error < StandardError; end
  extend ActiveSupport::Autoload
  class << self
    attr_accessor :logisticed_table, :logisticed_source_id_column_type, :logisticed_operator_id_column_type
    def config
      yield(self)
    end

    def logistic_class
      @logistic_class ||= Logistic
    end

    def store
      Thread.current[:logisticed_store] ||= {}
    end
  end

  @logisticed_table                   = :logistics
  @logisticed_source_id_column_type   = :integer
  @logisticed_operator_id_column_type = :integer
end

::ActiveRecord::Base.send :include, Logisticed::Sweeper

ActiveSupport.on_load(:active_record) do
  include Logisticed
end