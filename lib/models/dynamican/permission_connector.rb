module Dynamican
  class PermissionConnector < ActiveRecord::Base
    Dynamican.configuration.associations.each do |association_name, association_options|
      belongs_to association_name.to_sym, class_name: association_options[:class_name], inverse_of: association_options[:inverse_of], foreign_key: "#{association_name}_id".to_sym, optional: true
    end
    has_and_belongs_to_many :conditions, class_name: 'Dynamican::Condition', inverse_of: :permission_connectors, foreign_key: :permission_connector_id
    belongs_to :permission, class_name: 'Dynamican::Permission', inverse_of: :permission_connectors, foreign_key: :permission_id

    scope :conditional, -> { where(conditional: true) }
    scope :unconditional, -> { where(conditional: false) }
    scope :for_action, -> (action) { joins(:permission).where(permissions: { action: action }) }
    scope :for_object, -> (object_name) { joins(:permission).where(permissions: { object_name: object_name }) }
  end
end
