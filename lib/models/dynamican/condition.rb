module Dynamican
  class Condition < ActiveRecord::Base
    has_and_belongs_to_many :permission_connectors, class_name: 'Dynamican::PermissionConnector', foreign_key: :condition_id
  end
end
