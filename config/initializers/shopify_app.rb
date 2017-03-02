ShopifyApp.configure do |config|
  config.api_key = ENV["API_KEY"]
  config.secret = ENV["SECRET"]
  if Rails.env.production?
	  config.redirect_uri = "https://easydash.herokuapp.com/auth/shopify/callback"
	else
		config.redirect_uri = "https://localhost:3000/auth/shopify/callback"
	end
  config.scope = "read_content, write_content, read_themes, write_themes, read_products, write_products, read_script_tags, write_script_tags"
  config.embedded_app = true
end
