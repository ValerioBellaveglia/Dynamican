module Dynamican
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :permission_connectors, class_name: 'Dynamican::PermissionConnector'
      has_many :permissions, class_name: 'Dynamican::Permission', through: :permission_connectors, source: :permission
    end

    def can?(action, object, conditions_instances = {})
      if object.respond_to? :each
        object.all? { |single_object| can? action, single_object }
      else
        Dynamican::Evaluator.new(self, action, object, conditions_instances).evaluate
      end
    end
  end
end
