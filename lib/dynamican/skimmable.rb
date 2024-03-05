module Dynamican
    module Skimmable
      extend ActiveSupport::Concern
  
      included do
        has_many :filters, class_name: 'Dynamican::Filter', as: :skimmable
      end
  
      module ClassMethods
        def skim_through(association)
          has_many :filters, through: association, class_name: 'Dynamican::Filter', source: :filters
        end
      end
  
      def skim(collection, item_name: nil, **skimming_instances)
        Dynamican::Skimmer.new(self, collection, item_name, skimming_instances).skim
      end
    end
  end
  