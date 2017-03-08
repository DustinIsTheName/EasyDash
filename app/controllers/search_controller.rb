class SearchController < AuthenticatedController
  skip_before_filter :verify_authenticity_token

  def products
    headers['Access-Control-Allow-Origin'] = '*'
  	products = ShopifyAPI::Product.find(:all, params: {title: params[:q], limit: 250})

  	render json: products
  end

  def articles
    headers['Access-Control-Allow-Origin'] = '*'
  	articles = ShopifyAPI::Article.find(:all, params: {title: params[:q], limit: 250})

  	render json: articles
  end

  def collections
    headers['Access-Control-Allow-Origin'] = '*'
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
    headers['Access-Control-Allow-Origin'] = '*'
  	pages = ShopifyAPI::Page.find(:all, params: {title: params[:q], limit: 250})

  	render json: pages
  end

end