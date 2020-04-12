module Dynamican
  class Permission < ActiveRecord::Base
    has_many :permission_connectors, class_name: 'Dynamican::PermissionConnector', inverse_of: :permission, foreign_key: :permission_id

    validates_presence_of :action

    scope :for_action, -> (actions) { where(action: actions) }
    scope :for_object, -> (object_names) { where(object_name: object_names) }
  end
end
