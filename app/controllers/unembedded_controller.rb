class UnembeddedController < ApplicationController
  include UnembeddedHelper
	before_action :login_again_if_different_shop, :except =>[:app_uninstall]

  skip_before_filter :verify_authenticity_token, :only => [:update_api, :add_image_to_theme, :app_uninstall]
  around_filter :shopify_session, :except =>[:app_uninstall]
  layout 'application'

  def quick_select
    puts params

    if params["resource"] == 'product'
      @viewed_resource = ShopifyAPI::Product.find(:first, params: {handle: params["handle"]})      
    elsif params["resource"] == 'collection'
      @viewed_resource = ShopifyAPI::CustomCollection.find(:first, params: {handle: params["handle"]})
      @viewed_resource = ShopifyAPI::SmartCollection.find(:first, params: {handle: params["handle"]}) unless @viewed_resource
    elsif params["resource"] == 'page'
      @viewed_resource = ShopifyAPI::Page.find(:first, params: {handle: params["handle"]})
    elsif params["resource"] == 'blog'
      @viewed_resource = ShopifyAPI::Article.find(:first, params: {handle: params["handle"]})
    end

    # get_resources
  end

  def ajax_get_resources
    # get_resources

    respond_to do |format|
      format.js { panel "resource_select" }
    end
  end

  def dashboard
    @type = params[:resource]

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
      @smart_collections = ShopifyAPI::SmartCollection.find(:all, params: {product_id: params[:id], limit: 250, fields: ['title', 'handle', 'id']})
    end
    
    unless @resource
      # get_resources
      @type = 'resource_select'
    end

    @theme = ShopifyAPI::Theme.find(:first, params: {role: "main"})

  end

  def refresh_form
    puts Colorize.magenta(params)

    @type = params[:resource]

    case @type
    when 'blog'
      @resource = ShopifyAPI::Article.find(:first, params: {handle: params["handle"]})
    when 'custom_collection'
      @resource = ShopifyAPI::CustomCollection.find(:first, params: {handle: params["handle"]})
    when 'smart_collection'
      @resource = ShopifyAPI::SmartCollection.find(:first, params: {handle: params["handle"]})
    when 'page'
      @resource = ShopifyAPI::Page.find(:first, params: {handle: params["handle"]})
    when 'product'
      @resource = ShopifyAPI::Product.find(:first, params: {handle: params["handle"]})
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
      @fulfillment_services = ShopifyAPI::FulfillmentService.find(:all, params: {scope: :all, fields: ['name', 'handle']})
      @smart_collections = ShopifyAPI::SmartCollection.find(:all, params: {product_id: params[:id], limit: 250, fields: ['title', 'handle', 'id']})
    end

    unless @resource
      # get_resources
      @type = 'resource_select'
    end

    @theme = ShopifyAPI::Theme.find(:first, params: {role: "main"})

    render :json => { 
      :form_html => render_to_string('unembedded/_resource_form', :layout => false),
      :modals => render_to_string('unembedded/_product_modals', :layout => false)
    }

  end

  def refresh_variant_panel
    @resource = ShopifyAPI::Product.find(params[:id])

    render html: render_to_string('unembedded/panels/_all_variants', :layout => false)
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
    if params['variants'].keys[0] == 'new'
      @variant = ShopifyAPI::Variant.new
      @variant.prefix_options[:product_id] = params["product_id"]
      variant_params = params["variants"]["new"]
    else
      @variant = ShopifyAPI::Variant.find(params['variants'].keys[0])
      variant_params = params["variants"][@variant.id.to_s]
    end

    validation = Validate.variant(variant_params, params)
    if validation.is_valid
      variant = API.updateVariant(params, @variant)
      render json: variant
    else
      render json: validation
    end
  end

  def duplicate_product
    puts Colorize.magenta(params)
    product = API.duplicateProduct(params)
    redirect_to action: 'dashboard', resource: 'product', id: params[:id]
  end

  def reorder_variants
    puts Colorize.magenta(params)
    product = API.changeVariantOrder(params)
    render json: product.options
  end

  def edit_options
    puts Colorize.magenta(params)
    product = API.editOptions(params)
    render json: product.options
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

  def add_image_to_theme
    puts Colorize.magenta(params)
    @shop = Shop.find_by_shopify_domain(@shop_session.url)
    theme = @shop.pingTheme

    image = API.addImagesToTheme(params, theme)
    puts Colorize.cyan(image.split('/').last.split('?').first)
    
    new_image = Image.new
    new_image.name = image.split('/').last.split('?').first
    new_image.shop_id = @shop.id
    new_image.save

    render json: {link: image}
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
    @theme = ShopifyAPI::Theme.find(:first, params: {role: "main"})
    render :dashboard
  end

  def bulk_delete_api
    puts Colorize.magenta(params)
    resources = []
    params["resource_ids"].each do |id|
      resources.push(API.deleteResource({id: id.to_i, resource: params["resource"]}))
    end
    render json: resources
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

  def get_product_tags
    response = open("https://#{@shop_session.url}/search?view=easy_dash_tags").read
    render json: response
  end

  def get_product_types
    response = open("https://#{@shop_session.url}/search?view=easy_dash_types").read
    render json: response
  end

  def get_product_vendors
    response = open("https://#{@shop_session.url}/search?view=easy_dash_vendors").read
    render json: response
  end

  def app_uninstall
    # puts Colorize.magenta(params)

    verified = verify_webhook(request.body.read, request.headers["HTTP_X_SHOPIFY_HMAC_SHA256"])
    
    if verified
      @shop = Shop.find_by_shopify_domain(request.headers["HTTP_X_SHOPIFY_SHOP_DOMAIN"])
      puts Colorize.magenta(request.headers["HTTP_X_SHOPIFY_SHOP_DOMAIN"])
      ShopMailer.uninstall_email(@shop).deliver
    end

    head :ok, content_type: "text/html"
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

    def verify_webhook(data, hmac_header)
      digest  = OpenSSL::Digest.new('sha256')
      calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ENV["SECRET"], data)).strip
      if calculated_hmac == hmac_header
        puts Colorize.green("Verified!")
      else
        puts Colorize.red("Invalid verification!")
      end
      calculated_hmac == hmac_header
    end

end
