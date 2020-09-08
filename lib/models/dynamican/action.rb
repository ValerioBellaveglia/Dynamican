module Dynamican
  class Action < ActiveRecord::Base
    has_many :permissions, class_name: 'Dynamican::Permission', inverse_of: :action, foreign_key: :action_id

    validates :name, presence: true, uniqueness: true

    attr_readonly :name
  end
end
