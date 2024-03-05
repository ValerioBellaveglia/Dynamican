module Dynamican
  class Action < ActiveRecord::Base
    self.table_name = 'dynamican_actions'
    
    has_many :permissions, class_name: 'Dynamican::Permission', inverse_of: :action, foreign_key: :action_id, dependent: :destroy

    validates :name, presence: true, uniqueness: true
  end
end
