class UnembeddedController < ApplicationController
	before_action :login_again_if_different_shop
  skip_before_filter :verify_authenticity_token, :only => :update_api
  around_filter :shopify_session
  layout 'application'

  def quick_select
    get_resources
  end

  def dashboard
    @type = params[:resource]
    case @type
    when 'blog'
      @resource = ShopifyAPI::Article.find(params[:id])
    when 'collection'
      @resource = ShopifyAPI::CustomCollection.find(params[:id])

      unless @resource
        @resource = ShopifyAPI::SmartCollection.find(params[:id])
      end
    when 'page'
      @resource = ShopifyAPI::Page.find(params[:id])
    when 'product'
      @fulfillment_services = ShopifyAPI::FulfillmentService.find(:all, params: {scope: :all, fields: ['name', 'handle']})
      @resource = ShopifyAPI::Product.find(params[:id])
    else
      @type = 'resource_select'
      get_resources
    end
  end

  def update_api
    # .add_metafield

    puts Colorize.magenta(params);

    @type = params[:resource]
    case @type
    when 'blog'
      @resource = ShopifyAPI::Article.find(params[:id])
    when 'collection'
      @resource = ShopifyAPI::CustomCollection.find(params[:id])

      unless @resource
        @resource = ShopifyAPI::SmartCollection.find(params[:id])
      end
    when 'page'
      @resource = ShopifyAPI::Page.find(params[:id])
    when 'product'
      @fulfillment_services = ShopifyAPI::FulfillmentService.find(:all, params: {scope: :all, fields: ['name', 'handle']})
      @resource = ShopifyAPI::Product.find(params[:id])
    else
      @type = 'resource_select'
      get_resources
    end
    render :dashboard, resource: params[:resource], id: params[:id]
  end

  private

    def get_resources
      @product_count = ShopifyAPI::Product.count
      @article_count = ShopifyAPI::Article.count
      @page_count = ShopifyAPI::Page.count
      @collection_count = ShopifyAPI::CustomCollection.count + ShopifyAPI::SmartCollection.count

      api_params = {limit: 250, fields: ['title', 'handle', 'id']}

      @products = ShopifyAPI::Product.find(:all, params: api_params)
      @articles = ShopifyAPI::Article.find(:all, params: api_params)
      @pages = ShopifyAPI::Page.find(:all, params: api_params)
      @collections = []

      @cc = ShopifyAPI::CustomCollection.find(:all, params: api_params)
      @cc.each do |c|
        @collections << c
       end

      @sc = ShopifyAPI::SmartCollection.find(:all, params: api_params)
      @sc.each do |c|
       @collections << c
      end
    end

end
