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
end