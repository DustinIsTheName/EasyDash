class API

	def self.updateProduct(params)
    created_new_variants = false
    created_new_product = false

    # get product and write product's new information
    if params[:id] == "new"
      @product = ShopifyAPI::Product.new
    else
      @product = ShopifyAPI::Product.find(params[:id])
    end

    old_product = ShopifyAPI::Product.new(@product.attributes)

    @product.title = params["shopify_api_product"]["title"]
    @product.body_html = params["shopify_api_product"]["body_html"]
    @product.handle = params["shopify_api_product"]["handle"]
    @product.product_type = params["shopify_api_product"]["product_type"]
    @product.vendor = params["shopify_api_product"]["vendor"]
    @product.tags = params["shopify_api_product"]["tags"]
    @product.template_suffix = params["shopify_api_product"]["template_suffix"]

    if params["shopify_api_product"]["published_at"]
      unless params["shopify_api_product"]["old_published_at"]
        @product.published_at = Time.now
      end
    else
      @product.published_at = nil
    end

    # save product if anything's changed
    if old_product.attributes == @product.attributes
      puts Colorize.cyan(@product.title + ' skipped')
    else
      if @product.save
        puts Colorize.green(@product.title + ' saved ') + Colorize.orange(ShopifyAPI.credit_left)
        if params[:id] == 'new'
          created_new_product = true
        end
      else
        puts Colorize.red(@product.errors.messages)
        return @product.errors.messages
      end
    end

		# loop through product metafields, update and save any new information
    unless params[:id] == "new"
      @product.metafields.each do |metafield|
        old_metafield = ShopifyAPI::Metafield.new(metafield.attributes)
        if params["metafields"]
          m = params["metafields"][metafield.id.to_s]
        end

        if m
          if m["value"] == ""
            puts Colorize.red(metafield.key + ' deleted')
            metafield.destroy
          else

            metafield.value = m["value"]
            
            if old_metafield.attributes == metafield.attributes
              puts Colorize.cyan(metafield.key + ' skipped')
            else
              if metafield.save
                puts Colorize.green(metafield.key + ' saved ') + Colorize.orange(ShopifyAPI.credit_left)
              else
                puts Colorize.red(metafield.errors.messages)
              end
            end
            
          end
        end
      end
    end

    # loop through any new metafields and create them
    if params["new_metafields"]
      params["new_metafields"].each do |new_metafield|
        @product.add_metafield(ShopifyAPI::Metafield.new({
          namespace: 'global',
          key: new_metafield["name"],
          value: new_metafield["value"],
          value_type: 'string'
        }))
      end
    end

    if params["shopify_api_product"]["files"]
      for uploaded_file in params["shopify_api_product"]["files"]
        # base64_file = Base64.encode64(uploaded_file.read)
        @product.images << ShopifyAPI::Image.new(attachment: uploaded_file)
        if @product.save
          puts Colorize.green('image created')
        else 
          puts Colorize.red(@product.errors.messages)
        end
      end
    end

    # add or remove collections from the product
    if params["collections"]
      new_collections = params["collections"].map{|par| par.to_i}
    else
      new_collections = []
    end
    if params[:id] == 'new'
      add_collections = new_collections
    else
      old_collections = @product.collections.map{|c| c.id.to_i}
      remove_collections = old_collections - new_collections
      add_collections = new_collections - old_collections

      remove_collections.each do |r|
        if ShopifyAPI::Collect.find(:first, params: {product_id: params[:id], collection_id: r}).destroy
          puts Colorize.red('deleted Collect')
        else
          puts Colorize.red('something went wrong')
        end
      end
    end

    add_collections.each do |a|
      product_id = params[:id] == 'new' ? @product.id : params[:id]

      if ShopifyAPI::Collect.create(product_id: product_id, collection_id: a)
        puts Colorize.green('created Collect')
      else
        puts Colorize.red('something went wrong')
      end
    end

		# loop through product variants and write proper information
    if params[:id] == 'new'
      @product.variants.first.price = params["variants"]["price"] if params["variants"]["price"]
      @product.variants.first.compare_at_price = params["variants"]["compare_at_price"] if params["variants"]["compare_at_price"]
      @product.variants.first.sku = params["variants"]["sku"] if params["variants"]["sku"]
      @product.variants.first.barcode = params["variants"]["barcode"] if params["variants"]["barcode"]
      @product.variants.first.taxable = params["variants"]["taxable"] if params["variants"]["taxable"]
      @product.variants.first.fulfillment_service = params["variants"]["fulfillment_service"] if params["variants"]["fulfillment_service"]
      @product.variants.first.inventory_management = params["variants"]["inventory_management"] if params["variants"]["inventory_management"]
      @product.variants.first.requires_shipping = params["variants"]["requires_shipping"] if params["variants"]["requires_shipping"]
      @product.variants.first.weight = params["variants"]["weight"] if params["variants"]["weight"]
      @product.variants.first.weight_unit = params["variants"]["weight_unit"] if params["variants"]["weight_unit"]
      if @product.save
        puts Colorize.green('created_new_variants')
        if params["variants"]['new_metafields']
          params["variants"]['new_metafields'].each do |new_metafield|
            @product.variants.first.add_metafield(ShopifyAPI::Metafield.new({
              namespace: 'global',
              key: new_metafield["name"],
              value: new_metafield["value"],
              value_type: 'string'
            }))
          end
        end
      else
        puts Colorize.red('error')
        puts @product.errors.messages
      end
    else
      @product.variants.each do |variant|
        updateVariant(params, variant)
      end
    end

    if params[:id] == "new"
      original_variant = params["variants"] # get Defaut Title variant
    else
      original_variant = params["variants"].values.first # get Defaut Title variant
    end

    # loop through and create new variants
    unless params["new_option_values_1"].nil? or params["new_option_values_1"]&.strip == ""
      new_option_values_1 = params["new_option_values_1"].split(",").map{ |v| v.strip }
      @product.options = []
      @product.variants = []
      @product.options << ShopifyAPI::Option.new(:name => params["new_option_1"])

      unless params["new_option_values_2"].nil? or params["new_option_values_2"]&.strip == ""
        new_option_values_2 = params["new_option_values_2"].split(",").map{ |v| v.strip }
        @product.options << ShopifyAPI::Option.new(:name => params["new_option_2"])

        unless params["new_option_values_3"].nil? or params["new_option_values_3"]&.strip == ""
          new_option_values_3 = params["new_option_values_3"].split(",").map{ |v| v.strip }
          @product.options << ShopifyAPI::Option.new(:name => params["new_option_3"])
          puts Colorize.blue('3 options')
          new_option_values_1.each do |option1|
            new_option_values_2.each do |option2|
              new_option_values_3.each do |option3|
                v = ShopifyAPI::Variant.new({
                  option1: option1,
                  option2: option2,
                  option3: option3,
                  price: original_variant["price"],
                  compare_at_price: original_variant["compare_at_price"],
                  sku: original_variant["sku"],
                  barcode: original_variant["barcode"],
                  taxable: original_variant["taxable"],
                  fulfillment_service: original_variant["fulfillment_service"],
                  inventory_management: original_variant["inventory_management"],
                  requires_shipping: original_variant["requires_shipping"],
                  weight: original_variant["weight"],
                  weight_unit: original_variant["weight_unit"],
                  metafields: [{
                    namespace: 'global',
                    key: original_variant['new_metafields'].first["name"],
                    value: original_variant['new_metafields'].first["value"],
                    value_type: 'string'
                  }]
                })

                @product.variants << v
              end
            end
          end
          @product.save
          puts Colorize.orange(ShopifyAPI.credit_left)
        else
          puts Colorize.purple('2 options')
          new_option_values_1.each do |option1|
            new_option_values_2.each do |option2|
              v = ShopifyAPI::Variant.new({
                option1: option1,
                option2: option2,
                price: original_variant["price"],
                compare_at_price: original_variant["compare_at_price"],
                sku: original_variant["sku"],
                barcode: original_variant["barcode"],
                taxable: original_variant["taxable"],
                fulfillment_service: original_variant["fulfillment_service"],
                inventory_management: original_variant["inventory_management"],
                requires_shipping: original_variant["requires_shipping"],
                weight: original_variant["weight"],
                weight_unit: original_variant["weight_unit"],
                metafields: [{
                  namespace: 'global',
                  key: original_variant['new_metafields'].first["name"],
                  value: original_variant['new_metafields'].first["value"],
                  value_type: 'string'
                }]
              })

              @product.variants << v
            end
          end
          @product.save
          puts Colorize.orange(ShopifyAPI.credit_left)
        end
      else
        puts Colorize.green('1 option')
        new_option_values_1.each do |option1|
          v = ShopifyAPI::Variant.new({
            option1: option1,
            price: original_variant["price"],
            compare_at_price: original_variant["compare_at_price"],
            sku: original_variant["sku"],
            barcode: original_variant["barcode"],
            taxable: original_variant["taxable"],
            fulfillment_service: original_variant["fulfillment_service"],
            inventory_management: original_variant["inventory_management"],
            requires_shipping: original_variant["requires_shipping"],
            weight: original_variant["weight"],
            weight_unit: original_variant["weight_unit"],
            metafields: [{
              namespace: 'global',
              key: original_variant['new_metafields'].first["name"],
              value: original_variant['new_metafields'].first["value"],
              value_type: 'string'
            }]
          })

          @product.variants << v
        end
        @product.save
        puts Colorize.orange(ShopifyAPI.credit_left)
      end

      created_new_variants = true
    end

    @product.created_new_product = created_new_product
    @product.created_new_variants = created_new_variants;

    @product
	end

  def self.updateVariant(params, variant)

    # make all attributes synonymous to their corosponding empty values from the form
    variant.attributes.each do |key, value| 
      variant.attributes[key] = "" if value.nil?
      variant.attributes[key] = "1" if value == true
      variant.attributes[key] = "0" if value == false
      variant.attributes[key] = variant.attributes[key].to_s
    end

    old_variant = ShopifyAPI::Variant.new(variant.attributes)
    if params[:id] == 'new'
      v = params["variants"]
    else
      if variant.id
        v = params["variants"][variant.id.to_s]
      else
        v = params["variants"]["new"]
      end
    end

    variant.option1 = v["option1"] if v["option1"]
    variant.option2 = v["option2"] if v["option2"]
    variant.option3 = v["option3"] if v["option3"]
    variant.price = v["price"] if v["price"]
    variant.compare_at_price = v["compare_at_price"] if v["compare_at_price"]
    variant.sku = v["sku"] if v["sku"]
    variant.inventory_quantity = v["inventory_quantity"] if v["inventory_quantity"]
    variant.taxable = v["taxable"] if v["taxable"]
    variant.barcode = v["barcode"] if v["barcode"]
    variant.inventory_management = v["inventory_management"] if v["inventory_management"]
    variant.requires_shipping = v["requires_shipping"] if v["requires_shipping"]
    variant.weight = v["weight"] if v["weight"]
    variant.weight_unit = v["weight_unit"] if v["weight_unit"]
    variant.fulfillment_service = v["fulfillment_service"] if v["fulfillment_service"]

    # save if anything has changed
    if old_variant.attributes == variant.attributes
      puts Colorize.cyan(variant.title + ' skipped')
    else
      if variant.save
        puts Colorize.green(variant.title + ' saved ') + Colorize.orange(ShopifyAPI.credit_left)
      else
        puts Colorize.red(variant.errors.messages)
      end
    end

    # only loop through metafields if data is sent for them
    if v["metafields"]
      variant.metafields.each do |metafield|
        old_metafield = ShopifyAPI::Metafield.new(metafield.attributes)
        m = v["metafields"][metafield.id.to_s]

        if m
          if m["value"].blank?
            metafield.destroy
          else

            metafield.value = m["value"]

            # save metafield if information has changed
            if old_metafield.attributes == metafield.attributes
              puts Colorize.cyan(metafield.key + ' skipped')
            else
              if metafield.save
                puts Colorize.green(metafield.key + ' saved ') + Colorize.orange(ShopifyAPI.credit_left)
              else
                puts Colorize.red(metafield.errors.messages)
              end
            end

          end
        end
      end
    end

    # loop through any new variant metafields and create them 
    if v["new_metafields"]
      v["new_metafields"].each do |new_metafield|
        variant.add_metafield(ShopifyAPI::Metafield.new({
          namespace: 'global',
          key: new_metafield["name"],
          value: new_metafield["value"],
          value_type: 'string'
        }))
      end
    end

    variant
  end

  def self.updatePage(params)
    if params[:id] == "new"
      @page = ShopifyAPI::Page.new
    else
      @page = ShopifyAPI::Page.find(params[:id])
    end

    old_page = ShopifyAPI::Page.new(@page.attributes)

    @page.title = params["shopify_api_page"]["title"]
    @page.body_html = params["shopify_api_page"]["body_html"]
    @page.handle = params["shopify_api_page"]["handle"]
    @page.template_suffix = params["shopify_api_page"]["template_suffix"]

    if params["shopify_api_page"]["published_at"] == 'true'
      unless params["shopify_api_page"]["old_published_at"]
        @page.published_at = Time.now
      end
    else
      @page.published_at = nil
    end


    # loop through page metafields, update and save any new information
    unless params[:id] == "new"
      @page.metafields.each do |metafield|
        old_metafield = ShopifyAPI::Metafield.new(metafield.attributes)
        if params["metafields"]
          m = params["metafields"][metafield.id.to_s]
        end

        if m
          if m["value"] == ""
            puts Colorize.red(metafield.key + ' deleted')
            metafield.destroy
          else
            metafield.value = m["value"]
            
            if old_metafield.attributes == metafield.attributes
              puts Colorize.cyan(metafield.key + ' skipped')
            else
              if metafield.save
                puts Colorize.green(metafield.key + ' saved ') + Colorize.orange(ShopifyAPI.credit_left)
              else
                puts Colorize.red(metafield.errors.messages)
              end
            end
          end
        end
      end
    end

    # loop through any new metafields and create them
    if params["new_metafields"]
      params["new_metafields"].each do |new_metafield|
        @page.add_metafield(ShopifyAPI::Metafield.new({
          namespace: 'global',
          key: new_metafield["name"],
          value: new_metafield["value"],
          value_type: 'string'
        }))
      end
    end

    if @page.save
      puts Colorize.green(@page.title + ' saved')
    else 
      puts Colorize.red(@page.errors.messages)
    end

    @page
  end

  def self.updateVariantImage(variant_id, image_id)
    variant = ShopifyAPI::Variant.find(variant_id)
    if image_id == 'destroy'
      variant.image_id = nil
    else
      variant.image_id = image_id
    end
    puts variant.image_id
    if variant.save
      puts Colorize.green(variant.title + ' image saved ') + Colorize.orange(ShopifyAPI.credit_left)
    else
      puts Colorize.red(variant.errors.messages)
    end
  end

  def self.duplicateProduct(params)
    product = ShopifyAPI::Product.find(params[:id])
    new_product = ShopifyAPI::Product.new(product.attributes)
    new_product.id = nil
    new_product.title = params["new_title"]
    new_product.handle = params["new_title"].handle
    new_product.save
    new_product
  end

  def self.changeVariantOrder(params)
    product = ShopifyAPI::Product.find(params[:id])

    original_positions = product.options.map {|o| o.position}
    product.options.each_with_index do |option, index|
      product.options[index].position = params["options"][option.id.to_s]["index"].to_i + 1
      # product.options[index].values = params["options"][option.id.to_s]["values"]
    end
    new_positions = product.options.map {|o| o.position}
    product.options.sort_by! { |option| option.position}

    positions_change = Hash[new_positions.zip(original_positions)]

    product.variants.each do |variant|
      original_options = {}

      original_options["option1"] = variant.option1 if variant.option1
      original_options["option2"] = variant.option2 if variant.option2
      original_options["option3"] = variant.option3 if variant.option3

      variant.option1 = original_options["option"+positions_change[1].to_s] if variant.option1
      variant.option2 = original_options["option"+positions_change[2].to_s] if variant.option2
      variant.option3 = original_options["option"+positions_change[3].to_s] if variant.option3
    end

    values_list = params["options"].values.map {|o| o["values"]}
    index = 1

    if values_list[0]
      for value1 in values_list[0]
        if values_list[1]
          for value2 in values_list[1]
            if values_list[2]
              for value3 in values_list[2]
                v = product.variants.select { |v| v.option1 == value1 and v.option2 == value2 and v.option3 == value3 }.first
                if v
                  v.position = index
                  index += 1
                end
              end
            else
              v = product.variants.select { |v| v.option1 == value1 and v.option2 == value2 }.first
              if v
                v.position = index
                index += 1
              end
            end
          end
        else
          v = product.variants.select { |v| v.option1 == value1 }.first
          if v
            v.position = index
            index += 1
          end
        end
      end
    end

    product.variants.sort_by! { |variant| variant.position}

    if product.save
      puts Colorize.green('Variant order saved')
    else
      puts Colorize.red(product.errors.messages)
    end

    product
  end

  def self.editOptions(params)
    product = ShopifyAPI::Product.find(params[:id])

    params["option_names"].each do |new_option_name|
      option = product.options.select{|o| o.id == new_option_name.first.to_i}.first
      option.name = new_option_name.last if option
    end

    if product.save
      puts Colorize.green('Options saved')
    else
      puts Colorize.red(product.errors.messages)
    end

    product
  end

  def self.deleteResource(params)
    case params[:resource]
    when 'product'
      resource = ShopifyAPI::Product.find(params[:id])
    when 'custom_collection'
      resource = ShopifyAPI::CustomCollection.find(params[:id])
    when 'smart_collection'
      resource = ShopifyAPI::SmartCollection.find(params[:id])
    when 'page'
      resource = ShopifyAPI::Page.find(params[:id])
    when 'blog'
      resource = ShopifyAPI::Article.find(params[:id])
    when 'variant'
      resource = ShopifyAPI::Variant.find(params[:id])
    end
    if resource
      resource.destroy
      puts Colorize.red('deleted ' + resource.title)
      return resource
    else
      puts Colorize.red('something went wrong')
      puts params
      return nil
    end
  end

  def self.addImages(params)
    product = ShopifyAPI::Product.find(params[:id])
    images = params[:images]
    if images
      for image in images
        product.images << ShopifyAPI::Image.new(attachment: image)
      end
      if product.save
        puts Colorize.green(images.size.to_s + ' image(s) created')
      end
    end

    product
  end

  def self.addImageFromURL(params)
    product = ShopifyAPI::Product.find(params[:id])
    if params[:src]
      product.images << ShopifyAPI::Image.new(src: params[:src])
      if product.save
        puts Colorize.green('image created')
      end
    end

    product
  end

  def self.addImagesToTheme(params, theme)

    base64_file = Base64.encode64(params["file"].read)

    new_asset = ShopifyAPI::Asset.new
    new_asset.key = 'assets/' + params["file"].original_filename
    new_asset.attachment = base64_file
    new_asset.prefix_options[:theme_id] = theme.id
    if new_asset.save
      Colorize.green("Added Image to #{theme.name}")
      return new_asset.public_url
    else
      put Colorize.red("Something went wrong")
    end

  end

  def self.changeImageOrder(params)
    product = ShopifyAPI::Product.find(params[:id])
    product.images.each_with_index do |image, index|
      product.images[index].position = params["image_orders"][image.id.to_s]
    end
    if product.save
      puts Colorize.green('image order saved')
    end

    product
  end

  def self.deleteImage(params)
    image = ShopifyAPI::Image.find(params[:image_id], params: {product_id: params[:product_id]})
    image.destroy
    image
  end

end