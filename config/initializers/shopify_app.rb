ShopifyApp.configure do |config|
  config.api_key = ENV["API_KEY"]
  config.secret = ENV["SECRET"]
  if Rails.env.production?
	  config.redirect_uri = "#{APP_URL}/auth/shopify/callback"
	else
		config.redirect_uri = "#{DEV_URL}/auth/shopify/callback"
	end
  config.scope = "write_content, write_themes, write_products, write_script_tags, read_fulfillments"
  config.embedded_app = true
end
