module Dynamican
    class Rule < ActiveRecord::Base
        self.table_name = 'dynamican_rules'

      belongs_to :filter, class_name: 'Dynamican::Filter', inverse_of: :rule, foreign_key: :filter_id
  
      validates_presence_of :statement
    end
  end
  