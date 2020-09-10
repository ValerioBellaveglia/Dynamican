module Dynamican
  class Item < ActiveRecord::Base
    has_and_belongs_to_many :permissions, class_name: 'Dynamican::Permission', inverse_of: :items, foreign_key: :item_id, dependent: :destroy

    validates :name, presence: true, uniqueness: true

    attr_readonly :name

    before_validation :classify_name

    def classify_name
      self.name = self.name.classify
    end
  end
end
