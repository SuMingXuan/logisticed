# frozen_string_literal: true

require 'logisticed/version'

module Logisticed
  class Migration < Rails::Engine; end
  class Error < StandardError; end
  extend ActiveSupport::Autoload
  class << self
    attr_accessor :logisticed_table, :logisticed_source_id_column_type, :logisticed_operator_id_column_type, :current_user_method
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

  @current_user_method                = :current_user
  @logisticed_table                   = :logistics
  @logisticed_source_id_column_type   = :integer
  @logisticed_operator_id_column_type = :integer
end
require 'logisticed/logistic'
require 'logisticed/logisticer'
::ActiveRecord::Base.include Logisticed::Logisticer
require 'logisticed/sweeper'

ActiveSupport.on_load(:active_record) do
  include Logisticed
end
