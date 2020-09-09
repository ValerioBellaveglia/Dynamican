module Dynamican
  class Evaluator
    attr_reader :subject, :action, :item, :item_name, :conditions_instances

    def initialize(subject, action, item, conditions_instances = {})
      @subject = subject
      @action = action
      @item = item
      @item_name = calculate_item_name
      @conditions_instances = conditions_instances
    end

    def evaluate
      set_instance_variables

      matching_permissions = item.present? ? subject.permissions.for_action(action).for_item(item_name) : subject.permissions.for_action(action).without_item
      matching_permissions_statements = matching_permissions.conditional.map(&:conditions).flatten.map(&:statement)

      matching_permissions.unconditional.any? ||
      matching_permissions_statements.any? && matching_permissions_statements.map { |statement| eval statement }.all?
    end

    private

    def set_instance_variables
      instance_variable_set("@#{subject.class.name.demodulize.underscore}", subject)

      conditions_instances.each do |instance_name, instance_item|
        instance_variable_set("@#{instance_name}", instance_item)
      end
    end

    def calculate_item_name
      if item.class.in? [Symbol, String, Class]
        item.to_s.classify
      else
        item.class.name.demodulize
      end
    end
  end
end
