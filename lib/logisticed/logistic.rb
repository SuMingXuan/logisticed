module Logisticed
  class Logistic < ::ActiveRecord::Base
    belongs_to :source, polymorphic: true
    belongs_to :operator, polymorphic: true
  end
end