module Dynamican
  class Permission < ActiveRecord::Base
    self.table_name = 'dynamican_permissions'

    belongs_to :permittable, polymorphic: true
    belongs_to :action, class_name: 'Dynamican::Action', inverse_of: :permissions, foreign_key: :action_id
    has_and_belongs_to_many :items, class_name: 'Dynamican::Item', inverse_of: :permissions, foreign_key: :permission_id, join_table: :dynamican_items_dynamican_permissions
    has_many :conditions, class_name: 'Dynamican::Condition', inverse_of: :permission, foreign_key: :permission_id

    scope :for_action, -> (action_name) { joins(:action).where(action: { name: action_name }) }
    scope :for_item, -> (item_name) { joins(:items).where(items: { name: item_name.to_s.classify }) }
    scope :without_item, -> { left_outer_joins(:items).where(items: { id: nil }) }
    scope :conditional, -> { joins(:conditions) }
    scope :unconditional, -> { left_outer_joins(:conditions).where(conditions: { id: nil }) }
  end
end
