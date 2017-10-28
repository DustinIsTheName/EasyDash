class AddOwnerAndDomainToShop < ActiveRecord::Migration
  def change
  	add_column :shops, :shop_owner, :string
  	add_column :shops, :domain, :string
  end
end
