module Dynamican
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :permissions, class_name: 'Dynamican::Permission', as: :permittable, dependent: :destroy
    end

    def can?(action, item = nil, conditions_instances = {})
      if item.respond_to? :each
        item.all? { |single_item| can? action, single_item }
      else
        Dynamican::Evaluator.new(self, action, item, conditions_instances).evaluate
      end
    end
  end
end
