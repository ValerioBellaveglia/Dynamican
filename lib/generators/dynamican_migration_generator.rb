require 'rails/generators'

class DynamicanMigrationGenerator < Rails::Generators::Base

  def create_migration_file
    create_file "db/migrate/#{Time.zone.now.strftime("%Y%m%d%H%M%S")}_dynamican_migration.rb", migration_data
  end

  private

  def migration_data
<<MIGRATION
class DynamicanMigration < ActiveRecord::Migration[5.2]
  def change
    create_table :dynamican_permissions do |t|
      t.bigint :permittable_id
      t.string :permittable_type
      t.bigint :action_id

      t.timestamps
    end

    create_table :dynamican_actions do |t|
      t.string :name

      t.timestamps
    end

    create_table :dynamican_items do |t|
      t.string :name

      t.timestamps
    end

    create_table :dynamican_conditions do |t|
      t.bigint :permission_id
      t.string :statement
      t.string :description

      t.timestamps
    end

    create_table :dynamican_filters do |t|
      t.bigint :item_id
      t.bigint :skimmable_id
      t.string :skimmable_type

      t.timestamps
    end

    create_table :dynamican_rules do |t|
      t.bigint :filter_id
      t.string :statement
      t.string :name

      t.timestamps
    end

    create_table :dynamican_items_dynamican_permissions do |t|
      t.bigint :item_id
      t.bigint :permission_id
    end
  end
end
MIGRATION
  end
end
