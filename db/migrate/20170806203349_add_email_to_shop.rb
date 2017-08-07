class AddEmailToShop < ActiveRecord::Migration
  def change
    add_column :shops, :email, :string
  end
end
