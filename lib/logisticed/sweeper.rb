# frozen_string_literal: true

module Logisticed
  class Sweeper
    STORED_DATA = {
      current_remote_address: :remote_ip,
      current_request_uuid: :request_uuid,
      current_user: :current_user
    }

    delegate :store, to: ::Logisticed

    def around(controller)
      self.controller = controller
      # set store[:current_remote_address], store[:current_request_uuid], store[:current_user]
      STORED_DATA.each { |k, m| store[k] = send(m) }
      yield
    ensure
      self.controller = nil
      STORED_DATA.keys.each { |k| store.delete(k) }
    end

    def current_user
      lambda do
        if controller.respond_to?(Logisticed.current_user_method, true)
          controller.send(Logisticed.current_user_method)
        end
      end
    end

    def controller
      store[:current_controller]
    end

    def controller=(value)
      store[:current_controller] = value
    end

    def remote_ip
      controller.try(:request).try(:remote_ip)
    end

    def request_uuid
      controller.try(:request).try(:uuid)
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  if defined?(ActionController::Base)
    # Logisticed::Sweeper.new 的目的是保证每次访问一个action时都是一个单独的线程
    ActionController::Base.around_action Logisticed::Sweeper.new
  end
  if defined?(ActionController::API)
    ActionController::API.around_action Logisticed::Sweeper.new
  end
end