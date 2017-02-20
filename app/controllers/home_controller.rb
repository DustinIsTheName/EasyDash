class HomeController < AuthenticatedController
	# protect_from_forgery except: :index

  def index
  	file = getJSfile
  	@shop = Shop.find_by_shopify_domain(@shop_session.url)
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 10})
    @shop.createScriptTag(file)
  end

  private

    def getJSfile
			file = render_to_string(:template => "home/index.html", :layout => false)
			return file
    end

end
