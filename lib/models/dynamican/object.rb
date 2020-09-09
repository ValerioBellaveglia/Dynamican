module Dynamican
  class Object < ActiveRecord::Base
    has_and_belongs_to_many :permissions, class_name: 'Dynamican::Permission', inverse_of: :objects, foreign_key: :object_id, dependent: :destroy

    validates :name, presence: true, uniqueness: true

    attr_readonly :name

    def name
      super.classify
    end
  end
end
