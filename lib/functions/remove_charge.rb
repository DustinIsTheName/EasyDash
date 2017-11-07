class RemoveCharge

	def self.single_store(shop)
		session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
		ShopifyAPI::Base.activate_session(session)
		
		if ShopifyAPI::RecurringApplicationCharge.current&.destroy
			puts Colorize.red(shop.domain + ' charge removed')
		else
			puts Colorize.cyan(shop.domain + ' charge didn\'t exit')
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