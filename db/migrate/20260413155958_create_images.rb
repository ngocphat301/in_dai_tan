class CreateImages < ActiveRecord::Migration[8.1]
  def change
    create_table :images do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.string :caption

      t.timestamps
    end
  end
end
