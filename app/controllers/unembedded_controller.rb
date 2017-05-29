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

    if session[:question]
      @question = @user.questions.new(session[:question])
      session[:question] = nil
      @question.valid? # run validations to to populate the errors[]
    else

      get_resources
      case @type
      when 'blog'
        @resource = ShopifyAPI::Article.find(params[:id])
      when 'custom_collection'
        @resource = ShopifyAPI::CustomCollection.find(params[:id])
      when 'smart_collection'
        @resource = ShopifyAPI::SmartCollection.find(params[:id])
      when 'page'
        @resource = ShopifyAPI::Page.find(params[:id])
      when 'product'
        @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
        @fulfillment_services = ShopifyAPI::FulfillmentService.find(:all, params: {scope: :all, fields: ['name', 'handle']})
        @resource = ShopifyAPI::Product.find(params[:id])
        @smart_collections = ShopifyAPI::SmartCollection.find(:all, params: {product_id: params[:id], limit: 250, fields: ['title', 'handle', 'id']})
      else
        @type = 'resource_select'
      end

    end
  end

  def update_api
    puts Colorize.magenta(params)

    product = API.updateProduct(params)

    # redirect_to dashboard_path(resource: params[:resource], id: params[:id])
    render json: product
  end

  def update_variant
    # puts Colorize.magenta(params)
    @variant = ShopifyAPI::Variant.find(params['variants'].keys[0])

    variant = API.updateVariant(params, @variant)
    render json: variant
  end

  def add_images
    puts Colorize.magenta(params)
    # API.addImages()
    render json: params
  end

  def update_variant_image
    # puts Colorize.magenta(params)
    API.updateVariantImage(params['variant'], params['image'])
    if params['image'] == 'destroy'
      render json: {id: nil, src: nil}
    else
      @image = ShopifyAPI::Image.find(params['image'], params: {product_id: params['product']})
      render json: @image
    end
  end

  def delete_api
    puts Colorize.magenta(params)
    resource = API.deleteResource(params)
    render json: resource
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
