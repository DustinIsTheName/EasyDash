class UnembeddedController < ApplicationController
  include UnembeddedHelper
	before_action :login_again_if_different_shop, :except =>[:app_uninstall]

  skip_before_filter :verify_authenticity_token, :only => [:update_api, :add_image_to_theme, :app_uninstall]
  around_filter :shopify_session, :except =>[:app_uninstall]
  layout 'application'

  def quick_select
    puts params

    @shop = Shop.find_by_shopify_domain(@shop_session.url)
    if cookies['front_end_token'] == @shop.front_end_token
      @is_admin = true
    else
      @is_admin = false
    end

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
      if params[:id] == 'new' 
        @resource = ShopifyAPI::Article.new(id: 'new', title: '', author: '', body_html: '', summary_html: '', created_at: '', blog_id: '', handle: '', updated_at: '', published_at: nil, tags: '', template_suffix: '')
      else 
        @resource = ShopifyAPI::Article.find(params[:id])
      end
      @shop = Shop.find_by_shopify_domain(@shop_session.url)
      @blogs = ShopifyAPI::Blog.all
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
    when 'collection'
      @resource = ShopifyAPI::SmartCollection.new(id: 'new', title: '', body_html: '', disjunctive: '', created_at: '', sort_order: '', handle: '', updated_at: '', rules: [], published_at: nil, template_suffix: '')
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
    when 'custom_collection'
      if params[:id] == 'new'
        @resource = ShopifyAPI::CustomCollection.new 
      else
        @resource = ShopifyAPI::CustomCollection.find(params[:id])
      end
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
    when 'smart_collection'
      if params[:id] == 'new'
        @resource = ShopifyAPI::SmartCollection.new
      else 
        @resource = ShopifyAPI::SmartCollection.find(params[:id])
      end
     @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
    when 'page'
      if params[:id] == 'new' 
        @resource  = ShopifyAPI::Page.new(id: 'new',title: '', body_html: '', created_at: '', handle: '', updated_at: '', published_at: nil, template_suffix: '')
      else
        @resource = ShopifyAPI::Page.find(params[:id])
      end
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
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
      @shop = Shop.find_by_shopify_domain(@shop_session.url)
      @blogs = ShopifyAPI::Blog.all
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
    when 'collection'
      @resource = ShopifyAPI::CustomCollection.find(:first, params: {handle: params["handle"]})
      @type = 'custom_collection'
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
      unless @resource
        @resource = ShopifyAPI::SmartCollection.find(:first, params: {handle: params["handle"]})
        @type = 'custom_collection'
      end
    when 'page'
      @resource = ShopifyAPI::Page.find(:first, params: {handle: params["handle"]})
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
    when 'product'
      @resource = ShopifyAPI::Product.find(:first, params: {handle: params["handle"]})
      @assets = ShopifyAPI::Asset.find(:all, params: {fields: ['key']})
      @fulfillment_services = ShopifyAPI::FulfillmentService.find(:all, params: {scope: :all, fields: ['name', 'handle']})
      @smart_collections = ShopifyAPI::SmartCollection.find(:all, params: {product_id: @resource.id, limit: 250, fields: ['title', 'handle', 'id']})
    end

    unless @resource
      # get_resources
      @type = 'resource_select'
    end

    @theme = ShopifyAPI::Theme.find(:first, params: {role: "main"})

    render :json => { 
      :form_html => render_to_string('unembedded/_resource_form', :layout => false),
      :modals => render_to_string('unembedded/_resource_modals', :layout => false)
    }

  end

  def refresh_variant_panel
    @resource = ShopifyAPI::Product.find(params[:id])

    render html: render_to_string('unembedded/panels/_all_variants', :layout => false)
  end

  def update_api
    puts Colorize.magenta(params)
    case params[:resource]
    when 'blog'
      validation = Validate.blog(params)
      if validation.is_valid
        if params["shopify_api_article"]["author"] == 'create_new_author'
          params["shopify_api_article"]["author"] = params["shopify_api_article"]["new_author_name"]

          unless Author.find_by_name(params["shopify_api_article"]["new_author_name"])
            @shop = Shop.find_by_shopify_domain(@shop_session.url)
            new_author = Author.new
            new_author.name = params["shopify_api_article"]["new_author_name"]
            new_author.shop_id = @shop.id
            new_author.save
          end
        end

        blog = API.updateBlog(params)
        render json: blog
      else
        render json: validation
      end
    when 'collection'
      validation = Validate.smart_collection(params)
      if validation.is_valid
        new_collection = API.createCollection(params)
        render json: new_collection
      else
        render json: validation
      end
    when 'custom_collection'
      validation = Validate.custom_collection(params)
      if validation.is_valid
        custom_collection = API.updateCustomCollection(params)
        render json: custom_collection
      else
        render json: validation
      end
    when 'smart_collection'
      validation = Validate.smart_collection(params)
      if validation.is_valid
        smart_collection = API.updateSmartCollection(params)
        render json: smart_collection
      else
        render json: validation
      end
    when 'page'
      validation = Validate.page(params)
      if validation.is_valid
        page = API.updatePage(params)
        render json: page
      else
        render json: validation
      end
    when 'product'
      validation = Validate.product(params)
      if validation.is_valid
        product = API.updateProduct(params)
        render json: product
      else
        render json: validation
      end
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

  def add_product_images
    # puts Colorize.magenta(params)
    product = API.addProductImages(params)
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
    if params[:id]
      resource = API.deleteResource(params)
    end
    # get_resources
    @type = 'resource_select'
    @theme = ShopifyAPI::Theme.find(:first, params: {role: "main"})
    redirect_to :dashboard
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

  def get_resource_seo
    puts Colorize.magenta(params)
    seo_info = ShopifyAPI::Metafield.find(:all, params: {"metafield[owner_id]" => params[:resource_id], "metafield[owner_resource]" => params[:resource_type].gsub('blog', 'article')})
    render json: seo_info
  end

  def get_product_tags
    response = open("https://#{@shop_session.url}/search?view=easy_dash_tags").read
    render json: response
  end

  def get_blog_tags
    response = '['
    blogs = ShopifyAPI::Blog.all
    blogs.each_with_index do |b, i|
      unless i == 0
        response += ','
      end
      response += open("https://#{@shop_session.url}/blogs/"+b.handle+"?view=easy_dash_tags").read
    end
    response += ']'

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

  def get_iframe_content
    puts params

    @type = params["resource"]

    unless @type == 'resource_select' or @type == nil
      if @type.include? 'collection'
        resource_url = 'collections/'
      elsif @type.include? 'blog'
        @resource = ShopifyAPI::Article.find(:first, params: {handle:params["handle"]})
        @blogs = ShopifyAPI::Blog.all
        blog = @blogs.select{|b| b.id == @resource.blog_id}.first
        if blog
          resource_url = 'blogs/' + blog.handle + '/'
        else
          resource_url = ''
        end
      else
        resource_url = @type + 's/'
      end
      
      resource_url = resource_url + params["handle"]
    else
      resource_url = ''
    end
    
    # render html: open("https://#{@shop_session.url}/#{resource_url}?ediframe=true").read.html_safe
    uri = URI.parse("https://#{@shop_session.url}/#{resource_url}?ediframe=true")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = session[:iframe_cookies] ? { 'Cookie' => session[:iframe_cookies] } : {}
    response = http.get(uri, headers)
    store_cookies(response.get_fields('set-cookie'))

    while response.code == "301" or response.code == "302"
      headers = session[:iframe_cookies] ? { 'Cookie' => session[:iframe_cookies] } : {}
      response = http.get(URI.parse(response['location']), headers)
      store_cookies(response.get_fields('set-cookie'))
    end

    render html: response.body.html_safe
  end

  def get_from_site
    uri = URI.parse("https://#{@shop_session.url}#{params['url']}?ediframe=true")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = session[:iframe_cookies] ? { 'Cookie' => session[:iframe_cookies] } : {}
    response = http.get(uri, headers)
    store_cookies(response.get_fields('set-cookie'))

    while response.code == "301" or response.code == "302"
      headers = session[:iframe_cookies] ? { 'Cookie' => session[:iframe_cookies] } : {}
      response = http.get(URI.parse(response['location']), headers)
      store_cookies(response.get_fields('set-cookie'))
    end

    render html: response.body.html_safe
  end

  def post_to_site
    uri = URI.parse("https://#{@shop_session.url}#{params['url']}?ediframe=true")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = session[:iframe_cookies] ? { 'Cookie' => session[:iframe_cookies] } : {}
    response = http.post(uri, params["params"], headers)
    store_cookies(response.get_fields('set-cookie'))

    while response.code == "301" or response.code == "302"
      headers = session[:iframe_cookies] ? { 'Cookie' => session[:iframe_cookies] } : {}
      response = http.get(URI.parse(response['location']), headers)
      store_cookies(response.get_fields('set-cookie'))
    end

    render html: response.body.html_safe
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

    def store_cookies(all_cookies)
      cookie_hash = {}
      session[:iframe_cookies]&.split('; ')&.each do |c|
        split_cookie = c.split('=')
        cookie_hash[split_cookie[0]] = split_cookie[1]
      end

      old_cookies_array = Array.new
      all_cookies&.each { | cookie |
        cleaned_cookie = cookie.split('; ')[0]
        old_cookies_array.push(cleaned_cookie)
        split_cookie = cleaned_cookie.split('=')
        cookie_hash[split_cookie[0]] = split_cookie[1]
      }

      cookies_array = Array.new
      cookie_hash.each do |c, v|
        if c
          if v
            cookies_array.push(c + '=' + v)
          else
            cookies_array.push(c + '=')
          end
        end
      end

      cookies = cookies_array.join('; ')
      session[:iframe_cookies] = cookies
    end

end
