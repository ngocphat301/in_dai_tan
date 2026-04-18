class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price_vnd, null: false, default: 0
      t.boolean :published, null: false, default: true

      t.timestamps
    end
  end
end
