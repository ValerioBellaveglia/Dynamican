module Dynamican
  class Evaluator
    attr_reader :subject, :action, :object, :object_name, :conditions_instances

    def initialize(subject, action, object, conditions_instances = {})
      @subject = subject
      @action = action
      @object = object
      @object_name = calculate_object_name
      @conditions_instances = conditions_instances
    end

    def evaluate
      set_instance_variables

      matching_permissions = object.present? ? subject.permissions.for_action(action).for_object(object_name) : subject.permissions.for_action(action).without_object
      matching_permissions_statements = matching_permissions.conditional.map(&:conditions).flatten.map(&:statement)

      matching_permissions.unconditional.any? ||
      matching_permissions_statements.any? && matching_permissions_statements.map { |statement| eval statement }.all?
    end

    private

    def set_instance_variables
      instance_variable_set("@#{subject.class.name.demodulize.underscore}", subject)

      conditions_instances.each do |instance_name, instance_object|
        instance_variable_set("@#{instance_name}", instance_object)
      end
    end

    def calculate_object_name
      if object.class.in? [Symbol, String, Class]
        object.to_s.classify
      else
        object.class.name.demodulize
      end
    end
  end
end
