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
        @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
        @fulfillment_services = ShopifyAPI::FulfillmentService.find(:all, params: {scope: :all, fields: ['name', 'handle']})
        @resource = ShopifyAPI::Product.find(params[:id])
      else
        @type = 'resource_select'
        get_resources
      end

    end
  end

  def update_api
    # .add_metafield
    puts Colorize.magenta(params)

    case params[:resource]
    when 'blog'
    when 'collection'
    when 'page'
    when 'product'
      successes = 0
      failures = 0

      @product = ShopifyAPI::Product.find(params[:id])

      @product.title = params["shopify_api_product"]["title"]
      @product.body_html = params["shopify_api_product"]["body_html"]
      @product.handle = params["shopify_api_product"]["handle"]
      @product.product_type = params["shopify_api_product"]["product_type"]
      @product.vendor = params["shopify_api_product"]["vendor"]
      @product.tags = params["shopify_api_product"]["tags"]
      @product.template_suffix = params["shopify_api_product"]["template_suffix"]

      if @product.save
        successes += 1
      else
        failures += 1
      end

      @product.metafields.each do |metafield|
        m = params["metafields"][metafield.id.to_s]

        metafield.value = m["value"]
        
        if metafield.save
          successes += 1
        else
          failures += 1
        end
      end

      @product.variants.each do |variant|
        v = params["variants"][variant.id.to_s]

        variant.price = v["price"]
        variant.compare_at_price = v["compare_at_price"]
        variant.taxable = v["taxable"]
        variant.sku = v["sku"]
        variant.barcode = v["barcode"]
        variant.inventory_management = v["inventory_management"]
        variant.requires_shipping = v["requires_shipping"]
        variant.weight = v["weight"]
        variant.weight_unit = v["weight_unit"]
        variant.fulfillment_service = v["fulfillment_service"]

        if variant.save
          successes += 1
        else
          failures += 1
        end

        variant.metafields.each do |metafield|
          m = v["metafields"][metafield.id.to_s]

          metafield.value = m["value"]

          if metafield.save
            successes += 1
          else
            failures += 1
          end
        end

      end

    end

    puts Colorize.green('successes: '<<successes)
    puts Colorize.red('failures: '<<failures)

    redirect_to dashboard_path(resource: params[:resource], id: params[:id])
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
