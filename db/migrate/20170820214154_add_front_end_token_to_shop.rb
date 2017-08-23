class AddFrontEndTokenToShop < ActiveRecord::Migration
  def change
    add_column :shops, :front_end_token, :string
  end
end
