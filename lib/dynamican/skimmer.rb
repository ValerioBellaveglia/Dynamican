module Dynamican
    class Skimmer
      attr_reader :subject, :collection, :item_name, :skimming_instances
  
      def initialize(subject, collection, item_name, skimming_instances)
        @subject = subject
        @collection = collection
        @item_name = calculate_item_name
        @skimming_instances = skimming_instances
      end
  
      def skim
        set_instance_variables
  
        filters_rules = subject.filters.for_item(item_name).map(&:rules).flatten.map(&:statement)
  
        return collection if filters_rules.empty?
  
        skimming_result = collection.select do |collection_item|
          instance_variable_set("@#{item_name.downcase}", collection_item)
  
          filters_rules.all? { |rule| eval rule }
        end
  
        skimming_result
      end
  
      private
  
      def calculate_item_name
        return item_name.to_s.classify if item_name
  
        items_classes = collection.map(&:class).uniq
  
        raise 'Invalid collection: contains items with different classes (#{items.classes.join(', ')}). Use same class items or specify their item_name.' unless items_classes.count == 1
  
        items_classes.first.name.demodulize
      end
  
      def set_instance_variables
        instance_variable_set("@#{subject.class.name.downcase}", subject)
  
        skimming_instances.each do |instance_name, instance_object|
          instance_variable_set("@#{instance_name}", instance_object)
        end
      end
    end
  end
  