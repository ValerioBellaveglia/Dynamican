module Dynamican
  class Item < ActiveRecord::Base
    self.table_name = 'dynamican_items'

    has_and_belongs_to_many :permissions, class_name: 'Dynamican::Permission', inverse_of: :items, foreign_key: :item_id, dependent: :destroy
    has_many :filters, class_name: 'Dynamican::Filter', inverse_of: :item, foreign_key: :item_id

    validates :name, presence: true, uniqueness: true

    before_validation :classify_name

    def classify_name
      self.name = self.name.classify
    end
  end
end
