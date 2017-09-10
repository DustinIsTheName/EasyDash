module OptionsHelper
	def inventory_management_options
	  [
	    ['Don\'t track inventory', ''], 
	    ['Shopify tracks this product\'s inventory', 'shopify']
	  ]
	end

	def weight_unit_options
		[
			['lb', 'lb'],
			['oz', 'oz'],
			['kg', 'kg'],
			['g', 'g']
		]
	end

	def sort_order_options
		[
			['Manually', 'manual'],
			['By best selling', 'best-selling'],
			['Alphabetically: A-Z', 'alpha-asc'],
			['Alphabetically: Z-A', 'alpha-desc'],
			['By price: Highest to lowest', 'price-desc'],
			['By price: Lowest to highest', 'price-asc'],
			['By date: Newest to oldest', 'created-desc'],
			['By date: Oldest to newest', 'created']
		]
	end

	def rules_column_options
		[
			['Product title', 'title', {'data-exceptions' => 'greater_than|less_than'}],
			['Product type', 'type', {'data-exceptions' => 'greater_than|less_than'}],
			['Product vendor', 'vendor', {'data-exceptions' => 'greater_than|less_than'}],
			['Product price', 'variant_price', {'data-exceptions' => 'starts_with|ends_with|contains|not_contains'}],
			['Product tag', 'tag', {'data-exceptions' => 'not_equals|greater_than|less_than|starts_with|ends_with|contains|not_contains'}],
			['Compare at price', 'variant_compare_at_price', {'data-exceptions' => 'starts_with|ends_with|contains|not_contains'}],
			['Weight', 'variant_weight', {'data-exceptions' => 'starts_with|ends_with|contains|not_contains'}],
			['Inventory stock', 'variant_inventory', {'data-exceptions' => 'not_equals|starts_with|ends_with|contains|not_contains'}],
			['Variant\'s title', 'variant_title', {'data-exceptions' => 'greater_than|less_than'}]
		]
	end

	def rules_relation_options
		[
			['is equal to', 'equals'],
			['is not equal to', 'not_equals'],
			['is greater than', 'greater_than'],
			['is less than', 'less_than'],
			['starts with', 'starts_with'],
			['ends with', 'ends_with'],
			['contains', 'contains'],
			['does not contain', 'not_contains']
		]
	end

	def fulfillment_service_options(fulfillment_services)
		options = [
			['Manual', 'manual']
		]

		for service in fulfillment_services
			options.push([service.name, service.handle])
		end

		options
	end

	def template_suffix_options(assets)
		options = []

		for asset in assets
			options.push([asset.key.gsub("templates/", "").gsub(".liquid", ""), asset.key.gsub(/templates\/(product|page|article|collection)/, "").gsub(".", "").gsub("liquid", "")])
		end

		options.sort
	end

	def article_blog_options(blogs)
		options = []

		for blog in blogs
			options.push([blog.title, blog.id])
		end

		options.push(['———————————————', 'separator'])
		options.push(['Create a new blog...', 'create_new_blog'])

		options
	end
end