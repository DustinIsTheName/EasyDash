class SearchController < AuthenticatedController
  skip_before_filter :verify_authenticity_token
  before_filter :set_params_and_headers

  def products
  	products = ShopifyAPI::Product.find(:all, params: @api_params)

  	render json: products
  end

  def blogs
  	articles = ShopifyAPI::Article.find(:all, params: @api_params)

  	render json: articles
  end

  def collections
    
  	@collections = []

		@cc = ShopifyAPI::CustomCollection.find(:all, params: @api_params)
		@cc.each do |c|
		  @collections << c
		 end

		@sc = ShopifyAPI::SmartCollection.find(:all, params: @api_params)
		@sc.each do |c|
		 @collections << c
		end

  	render json: @collections
  end

  def pages
  	pages = ShopifyAPI::Page.find(:all, params: @api_params)

  	render json: pages
  end

  private

    def set_params_and_headers
      headers['Access-Control-Allow-Origin'] = '*'

      @api_params = { title: params[:q], limit: 250, page: params[:page], fields: ['title', 'handle', 'id'] }
    end

end