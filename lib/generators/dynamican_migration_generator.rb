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
        create_table :permissions do |t|
          t.bigint :permittable_id
          t.string :permittable_type
          t.bigint :action_id

          t.timestamps
        end

        create_table :actions do |t|
          t.string :name

          t.timestamps
        end

        create_table :objects do |t|
          t.string :name

          t.timestamps
        end

        create_table :conditions do |t|
          t.bigint :permission_id
          t.string :statement
          t.string :description

          t.timestamps
        end

        create_table :objects_permissions do |t|
          t.bigint :object_id
          t.bigint :permission_id
        end
      end
    end
  end
MIGRATION
  end
end
