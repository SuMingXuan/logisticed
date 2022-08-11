module Logisticed
  class Logistic < ::ActiveRecord::Base
    belongs_to :source, polymorphic: true
    belongs_to :operator, polymorphic: true
    before_create :set_logistic_user, :set_request_info

    def self.as_user(user)
      last_logisticed_user = ::Logisticed.store[:logisticed_user]
      ::Logisticed.store[:logisticed_user] = user
      yield
    ensure
      ::Logisticed.store[:logisticed_user] = last_logisticed_user
    end

    private

    def set_logistic_user
      self.operator ||= ::Logisticed.store[:logisticed_user] # from .as_user
      self.operator ||= ::Logisticed.store[:current_user].try!(:call) # from Sweeper
      nil # prevent stopping callback chains
    end

    def set_request_info
      self.remote_ip    = ::Logisticed.store[:current_remote_address]
      self.request_uuid = ::Logisticed.store[:current_request_uuid]
    end
  end
end