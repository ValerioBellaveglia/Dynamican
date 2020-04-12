module Dynamican
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :permission_connectors, class_name: 'Dynamican::PermissionConnector'
      has_many :permissions, class_name: 'Dynamican::Permission', through: :permission_connectors, source: :permission
    end

    def can?(action, object, conditions_instances = {})
      @object = object
      instance_variable_set("@#{model_name.element}", self)
      conditions_instances.each do |instance_name, instance_object|
        instance_variable_set("@#{instance_name}", instance_object)
      end

      object_name = if object.class.in? [Symbol, String, Class]
                     object.to_s.downcase
                   elsif object.is_a?(NilClass)
                     nil
                   else
                     object.class.to_s.downcase
                   end

      matching_connectors = permission_connectors.for_action(action).for_object(object_name)
      matching_conditions_statements = matching_connectors.conditional.map(&:conditions).flatten.map(&:statement)

      matching_connectors.unconditional.any? ||
      matching_conditions_statements.any? && matching_conditions_statements.map { |statement| eval statement }.all?
    end
  end
end
