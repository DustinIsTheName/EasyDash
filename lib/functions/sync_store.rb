class SyncStore

	def self.single_store(shop)
		session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
		ShopifyAPI::Base.activate_session(session)
    begin
  		shop.getShopData
      shop.createScriptTag
    rescue => e
      puts e
    end 
		ShopifyAPI::Base.clear_session
	end

	def self.all_stores
		shops = Shop.all
		shops.each do |shop|
			single_store(shop)
		end
	end

end