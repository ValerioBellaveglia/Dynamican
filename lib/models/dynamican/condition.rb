module Dynamican
  class Condition < ActiveRecord::Base
    self.table_name = 'dynamican_conditions'

    belongs_to :permission, class_name: 'Dynamican::Permission', inverse_of: :conditions, foreign_key: :permission_id

    validates_presence_of :statement
  end
end
