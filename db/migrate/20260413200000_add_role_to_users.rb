# frozen_string_literal: true

class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    unless column_exists?(:users, :role)
      add_column :users, :role, :string, null: false, default: "member"
    end

    if column_exists?(:users, :admin)
      execute <<-SQL.squish
        UPDATE users SET role = 'admin' WHERE admin = TRUE
      SQL
      remove_column :users, :admin
    end
  end

  def down
    add_column :users, :admin, :boolean, null: false, default: false unless column_exists?(:users, :admin)

    if column_exists?(:users, :role)
      execute <<-SQL.squish
        UPDATE users SET admin = TRUE WHERE role = 'admin'
      SQL
      remove_column :users, :role
    end
  end
end
