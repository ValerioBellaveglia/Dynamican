require 'rails/generators'

class DynamicanMigrationGenerator < Rails::Generators::Base

  def create_migration_file
    create_file "db/migrate/#{Time.zone.now.strftime("%Y%m%d%H%M%S")}_dynamican_migration.rb", migration_data
  end

  private

  def migration_data
<<MIGRATION
  class DynamicanMigration < ActiveRecord::Migration[5.2]
    # 0.1.2 Release
    def change
      unless table_exists? :permissions
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
          #{create_migration_associations_data}
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
  end
MIGRATION
  end

  def create_migration_associations_data
    migration_associations_data = ""
    associations = Dynamican.configuration.associations.keys

    associations.each do |association|
      migration_associations_data += "t.references :#{association}#{"\n          " unless association == associations.last}"
    end

    migration_associations_data
  end
end
