class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :name
      t.integer :shop_id

      t.timestamps null: false
    end
  end
end
