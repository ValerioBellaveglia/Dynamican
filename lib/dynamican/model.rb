module Dynamican
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :permissions, class_name: 'Dynamican::Permission', inverse_of: :permittable, foreign_key: :permittable_id
    end

    def can?(action, object = nil, conditions_instances = {})
      if object.respond_to? :each
        object.all? { |single_object| can? action, single_object }
      else
        Dynamican::Evaluator.new(self, action, object, conditions_instances).evaluate
      end
    end
  end
end
