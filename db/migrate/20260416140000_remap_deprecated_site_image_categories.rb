# frozen_string_literal: true

class RemapDeprecatedSiteImageCategories < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL.squish
      UPDATE site_images
      SET category = 'poster'
      WHERE category IN ('ads', 'logo');
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
