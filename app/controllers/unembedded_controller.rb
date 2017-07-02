class UnembeddedController < ApplicationController
  include UnembeddedHelper
	before_action :login_again_if_different_shop
  skip_before_filter :verify_authenticity_token, :only => :update_api
  around_filter :shopify_session
  layout 'application'

  def quick_select
    get_resources
  end

  def ajax_get_resources
    get_resources

    respond_to do |format|
      format.js { panel "resource_select" }
    end
  end

  def dashboard
    t = Time.now
    @type = params[:resource]

    if session[:question]
      @question = @user.questions.new(session[:question])
      session[:question] = nil
      @question.valid? # run validations to to populate the errors[]
    else

      # get_resources
      case @type
      when 'blog'
        @resource = params[:id] == 'new' ? ShopifyAPI::Article.new : ShopifyAPI::Article.find(params[:id])
      when 'custom_collection'
        @resource = params[:id] == 'new' ? ShopifyAPI::CustomCollection.new : ShopifyAPI::CustomCollection.find(params[:id])
      when 'smart_collection'
        @resource = params[:id] == 'new' ? ShopifyAPI::SmartCollection.new : ShopifyAPI::SmartCollection.find(params[:id])
      when 'page'
        @resource = params[:id] == 'new' ? ShopifyAPI::Page.new : ShopifyAPI::Page.find(params[:id])
      when 'product'
        if params[:id] == 'new'
          @resource = ShopifyAPI::Product.new(id: 'new',title: '', body_html: '', vendor: '', product_type: '', created_at: '', handle: '', updated_at: '', published_at: '', template_suffix: '', published_scope: '', tags: '', variants: [], collections: [], options: [], images: [], image: '')
          @resource.variants << ShopifyAPI::Variant.new(title: 'Default Title', price: '', sku: '', position: '', grams: '', inventory_policy: '', compare_at_price: '', fulfillment_service: '', inventory_management: '', option1: 'Default Title', option2: nil, option3: nil, taxable: '', barcode: '', image_id: '', inventory_quantity: '', weight: '', weight_unit: '', old_inventory_quantity: '', requires_shipping: '')
        else
          @resource = ShopifyAPI::Product.find(params[:id])
        end
        @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
        @fulfillment_services = ShopifyAPI::FulfillmentService.find(:all, params: {scope: :all, fields: ['name', 'handle']})
        @custom_collections = ShopifyAPI::CustomCollection.find(:all, params: {limit: 250, fields: ['title', 'handle', 'id']})
        @smart_collections = ShopifyAPI::SmartCollection.find(:all, params: {product_id: params[:id], limit: 250, fields: ['title', 'handle', 'id']})
      else
        get_resources
        @type = 'resource_select'
      end
    end
  end

  def update_api
    puts Colorize.magenta(params)

    validation = Validate.product(params)
    if validation.is_valid
      product = API.updateProduct(params)
      render json: product
    else
      render json: validation
    end
  end

  def update_variant
    puts Colorize.magenta(params)
    @variant = ShopifyAPI::Variant.find(params['variants'].keys[0])
    variant_params = params["variants"][@variant.id.to_s]

    validation = Validate.variant(variant_params, params)
    if validation.is_valid
      variant = API.updateVariant(params, @variant)
      render json: variant
    else
      render json: validation
    end
  end

  def add_images
    # puts Colorize.magenta(params)
    product = API.addImages(params)
    render json: product.images
  end

  def add_image_from_url
    # puts Colorize.magenta(params)
    product = API.addImageFromURL(params)
    render json: product.images
  end

  def change_image_order
    puts Colorize.magenta(params)
    product = API.changeImageOrder(params)
    render json: product.images
  end

  def delete_image
    puts Colorize.magenta(params)
    image = API.deleteImage(params)
    render json: image
  end

  def update_variant_image
    puts Colorize.magenta(params)
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

  def hard_delete_api
    puts Colorize.magenta(params)
    resource = API.deleteResource(params)
    get_resources
    @type = 'resource_select'
    render :dashboard
  end

  def get_alt_tag
    alt_tag_metafield = ShopifyAPI::Metafield.find(:first, params: {"metafield[owner_id]" => params[:image_id], "metafield[owner_resource]" => 'product_image', key: 'alt'})
    render json: alt_tag_metafield
  end

  def edit_alt_tag
    puts Colorize.magenta(params)
    if params[:metafield_id] == 'new'
      metafield = ShopifyAPI::Metafield.new(namespace: "tags", key: "alt", value: params[:alt_tag], owner_id: params[:image_id], owner_resource: "product_image", value_type: "string")
      metafield.save
    else
      metafield = ShopifyAPI::Metafield.find(params[:metafield_id])
      metafield.value = params[:alt_tag]
      metafield.save
    end

    render json: metafield
  end

  def get_variant_hsc
    puts Colorize.magenta(params)
    hsc_metafield = ShopifyAPI::Metafield.find(:first, params: {"metafield[owner_id]" => params[:variant_id], "metafield[owner_resource]" => 'variant', key: 'harmonized_system_code'})
    render json: hsc_metafield
  end

  def get_product_seo
    puts Colorize.magenta(params)
    seo_info = ShopifyAPI::Metafield.find(:all, params: {"metafield[owner_id]" => params[:product_id], "metafield[owner_resource]" => 'product'})
    render json: seo_info
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
