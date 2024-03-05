module Dynamican
    class Filter < ActiveRecord::Base
        self.table_name = 'dynamican_filters'

      belongs_to :skimmable, polymorphic: true
      belongs_to :item, class_name: 'Dynamican::Item', inverse_of: :filters, foreign_key: :item_id
      has_many :rules
  
      validates_presence_of :rules
  
      scope :for_item, -> (item_name) { joins(:item).where(items: { name: item_name }) }
    end
  end
  