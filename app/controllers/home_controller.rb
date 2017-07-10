class HomeController < AuthenticatedController
	# protect_from_forgery except: :index

  def index
  	@shop = Shop.find_by_shopify_domain(@shop_session.url)
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 10})
    @shop.createScriptTag
    @shop.createTagTypeVendorQueryFiles
    cookies[:permanent_domain] = {
      :value => "#{@shop_session.url}",
      :expires => 2.years.from_now
    }
  end

end
