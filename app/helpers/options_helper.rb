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