class API

	def self.update(params)
    case params[:resource]
    when 'blog'
    when 'collection'
    when 'page'
    when 'product'
      successes = 0
      failures = 0
      identicals = 0
      i_arr = []

      # get product and write product's new information
      @product = ShopifyAPI::Product.find(params[:id])

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
        identicals += 1
        i_arr.push 'product'
      else
        if @product.save
          successes += 1
          puts Colorize.orange(ShopifyAPI.credit_left)
        else
          failures += 1
        end
      end

			# loop through product metafields, update and save any new information
      @product.metafields.each do |metafield|
        old_metafield = ShopifyAPI::Metafield.new(metafield.attributes)
        m = params["metafields"][metafield.id.to_s]

        if m
          metafield.value = m["value"]
          
          if old_metafield.attributes == metafield.attributes
            identicals += 1
            i_arr.push m["value"]
          else
            if metafield.save
              successes += 1
              puts Colorize.orange(ShopifyAPI.credit_left)
            else
              failures += 1
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

			# loop through product variants and write proper information
      @product.variants.each do |variant|

      	# make all attributes synonymous to their corosponding empty values from the form
        variant.attributes.each do |key, value| 
          variant.attributes[key] = "" if value.nil?
          variant.attributes[key] = "1" if value == true
          variant.attributes[key] = "0" if value == false
          variant.attributes[key] = variant.attributes[key].to_s
        end

        old_variant = ShopifyAPI::Variant.new(variant.attributes)
        v = params["variants"][variant.id.to_s]

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
          identicals += 1
          i_arr.push 'variant'
        else
          if variant.save
            successes += 1
            puts Colorize.orange(ShopifyAPI.credit_left)
          else
            failures += 1
            puts Colorize.red(variant.errors.messages)
          end
        end

        # only loop through metafields if data is sent for them
        if v["metafields"]
	        variant.metafields.each do |metafield|
	          old_metafield = ShopifyAPI::Metafield.new(metafield.attributes)
	          m = v["metafields"][metafield.id.to_s]

	          if m
	            metafield.value = m["value"]

	            # save metafield if information has changed
	            if old_metafield.attributes == metafield.attributes
	              identicals += 1
	              i_arr.push m["value"]
	            else
	              if metafield.save
	                successes += 1
	                puts Colorize.orange(ShopifyAPI.credit_left)
	              else
	                failures += 1
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

      end

      original_variant = params["variants"].values.first # get Defaut Title variant

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
                  v = @product.variants << ShopifyAPI::Variant.new({
                    option1: option1,
                    option2: option2,
                    option3: option3,
                    price: original_variant["price"],
                    compare_at_price: original_variant["compare_at_price"],
                    barcode: original_variant["barcode"],
                    taxable: original_variant["taxable"],
                    fulfillment_service: original_variant["fulfillment_service"],
                    inventory_management: original_variant["inventory_management"],
                    requires_shipping: original_variant["requires_shipping"],
                    weight: original_variant["weight"],
                    weight_unit: original_variant["weight_unit"]
                  })
                end
              end
            end
            @product.save
            puts Colorize.orange(ShopifyAPI.credit_left)
          else
            puts Colorize.purple('2 options')
            new_option_values_1.each do |option1|
              new_option_values_2.each do |option2|
                v = @product.variants << ShopifyAPI::Variant.new({
                  option1: option1,
                  option2: option2,
                  price: original_variant["price"],
                  compare_at_price: original_variant["compare_at_price"],
                  barcode: original_variant["barcode"],
                  taxable: original_variant["taxable"],
                  fulfillment_service: original_variant["fulfillment_service"],
                  inventory_management: original_variant["inventory_management"],
                  requires_shipping: original_variant["requires_shipping"],
                  weight: original_variant["weight"],
                  weight_unit: original_variant["weight_unit"]
                })
              end
            end
            @product.save
            puts Colorize.orange(ShopifyAPI.credit_left)
          end
        else
          puts Colorize.green('1 option')
          new_option_values_1.each do |option1|
            v = @product.variants << ShopifyAPI::Variant.new({
              option1: option1,
              price: original_variant["price"],
              compare_at_price: original_variant["compare_at_price"],
              barcode: original_variant["barcode"],
              taxable: original_variant["taxable"],
              fulfillment_service: original_variant["fulfillment_service"],
              inventory_management: original_variant["inventory_management"],
              requires_shipping: original_variant["requires_shipping"],
              weight: original_variant["weight"],
              weight_unit: original_variant["weight_unit"]
            })
          end
          @product.save
          puts Colorize.orange(ShopifyAPI.credit_left)
        end
      end

    end

    puts Colorize.green('successes: '<<successes.to_s)
    puts Colorize.red('failures: '<<failures.to_s)
    puts Colorize.cyan('identicals: '<<identicals.to_s<<' ')

    @product
	end

end