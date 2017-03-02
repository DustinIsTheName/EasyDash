class SearchController < AuthenticatedController

  def products
  	products = ShopifyAPI::Product.find(:all, params: {title: params[:q], limit: 250})

  	render json: products
  end

  def articles
  	articles = ShopifyAPI::Article.find(:all, params: {title: params[:q], limit: 250})

  	render json: articles
  end

  def collections
  	@collections = []

		@cc = ShopifyAPI::CustomCollection.find(:all, params: {title: params[:q], :limit => 250})
		@cc.each do |c|
		  @collections << c
		 end

		@sc = ShopifyAPI::SmartCollection.find(:all, params: {title: params[:q], :limit => 250})
		@sc.each do |c|
		 @collections << c
		end

  	render json: @collections
  end

  def pages
  	pages = ShopifyAPI::Page.find(:all, params: {title: params[:q], limit: 250})

  	render json: pages
  end

end