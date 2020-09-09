module Dynamican
  class Permission < ActiveRecord::Base
    belongs_to :permittable, polymorphic: true
    belongs_to :action, class_name: 'Dynamican::Action', inverse_of: :permissions, foreign_key: :action_id
    has_and_belongs_to_many :objects, class_name: 'Dynamican::Object', inverse_of: :permissions, foreign_key: :permission_id
    has_many :conditions, class_name: 'Dynamican::Condition', inverse_of: :permission, foreign_key: :permission_id

    scope :for_action, -> (action_name) { joins(:action).where(actions: { name: action_name }) }
    scope :for_object, -> (object_name) { joins(:objects).where(objects: { name: object_name.to_s.classify }) }
    scope :without_object, -> { left_outer_joins(:objects).where(objects: { id: nil }) }
    scope :conditional, -> { joins(:conditions) }
    scope :unconditional, -> { left_outer_joins(:conditions).where(conditions: { id: nil }) }
  end
end
