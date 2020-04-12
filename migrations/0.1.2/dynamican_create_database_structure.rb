class DynamicanCreateDatabaseStructure < ActiveRecord::Migration[5.2]
  def change
    create_table :conditions do |t|
      t.string :description
      t.string :statement

      t.timestamps
    end

    create_table :permissions do |t|
      t.string :action
      t.string :object_name

      t.timestamps
    end

    create_table :permission_connectors do |t|
      t.references :user
      t.references :role
      t.references :permission
      t.boolean :conditional, default: false

      t.timestamps
    end

    create_table :conditions_permission_connectors do |t|
      t.bigint :condition_id
      t.bigint :permission_connector_id
    end
  end
end
