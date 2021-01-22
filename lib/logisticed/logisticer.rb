# frozen_string_literal: true

module Logisticed
  module Logisticer
    extend ActiveSupport::Concern
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def logisticed(attr, options = {})
        struct = ListenerStruct.new(self, attr, options)
        has_many :logistics, -> { order(created_at: :asc) },
                 as: :source, class_name: Logisticed.logistic_class.name,
                 inverse_of: :source

        has_one :logistic, -> { order(created_at: :asc) },
                as: :source, class_name: Logisticed.logistic_class.name,
                inverse_of: :source

        struct.normalize_values.each do |value|
          has_many "#{value}_logistics".to_sym, -> { where(value: value).order(created_at: :asc) }, as: :source, class_name: Logisticed.logistic_class.name, inverse_of: :source
        end

        after_commit do
          if new_value = send("#{attr}_previous_change")&.last.presence
            execute_method_name = "#{attr}_change_to_#{new_value}"
            send(execute_method_name) if respond_to?(execute_method_name)
          end
        end

        class_eval do
          def value_change_by(value)
            logistics.where(value: value).last
          end

          struct.normalize_values.each do |value|
            define_method "#{value}_at" do
              value_change_by(value)&.created_at
            end

            define_method "#{value}_by" do
              value_change_by(value)&.operator
            end

            define_method "#{attr}_change_to_#{value}" do
              logistics.create(value: value)
            end
          end
        end
      end
    end

    class ListenerStruct
      class ArgumentError < StandardError; end
      extend Forwardable
      attr_reader :klass, :column, :options, :values
      def initialize(klass, column, options)
        @klass   = klass
        @column  = column.to_s
        @options = options
        @values  = options[:values]
      end

      def normalize_values
        @normalize_values ||= \
          if options[:only].present?
            (column_enum_values & options[:only]).uniq
          elsif options[:except].present?
            (column_enum_values - options[:only]).uniq
          else
            column_enum_values
          end
      end

      private

      def column_enum_values
        @column_enum_values ||= begin
          if values.present?
            case values
            when Hash
              values.keys.map(&:to_s)
            when Array
              values
            else
              raise ArgumentError, 'values must be Array or Hash'
            end
          else
            klass.send(column.pluralize).keys.map(&:to_s)
          end
        end
      end
    end
  end
end
