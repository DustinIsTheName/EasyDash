class Validate
	def self.product(params)

		if params["shopify_api_product"]["title"].blank?
			return {
				error_message: "Title can't be blank",
				is_valid: false
			}.extend(LookLikeJSON)
		end

		if params[:id] == 'new'
			variant_validations = variant(params["variants"], params)

      unless variant_validations.is_valid
      	return variant_validations
      end
		else
			params["variants"].each_with_index do |v, index|
	    	variant_validations = variant(v.last, params)

	      unless variant_validations.is_valid
	      	message_append = " for variant ##{index+1}"

	      	variant_validations.error_message << message_append
	      	return variant_validations
	      end
	    end
	  end

		{ is_valid: true }.extend(LookLikeJSON)
	end

	def self.variant(v, params)

		unless params[:id] == 'new'
			if params["options"]
		    for i in 0..2
			    if params["options"][i] and v["option#{i+1}"].blank?
						return {
							error_message: "You need to add option values for #{params["options"][i]}",
							is_valid: false
						}.extend(LookLikeJSON)
					end
		    end
		  end
	  end

		if v["price"].blank?
			return {
				error_message: "Price can't be blank",
				is_valid: false
			}.extend(LookLikeJSON)
		end

		if v["metafields"]
			harmonized_system_code = v["metafields"].values.select{|m| m["name"] === "harmonized_system_code"}[0]
		end
		if v["new_metafields"]
			harmonized_system_code = v["new_metafields"].select{|m| m["name"] === "harmonized_system_code"}[0]
		end

		if harmonized_system_code
			unless harmonized_system_code["value"].blank?
				if !harmonized_system_code["value"].is_i? or harmonized_system_code["value"].length < 6
					return {
						error_message: "Harmonized System Code must be a number of six or more digits",
						is_valid: false
					}.extend(LookLikeJSON)
				end
			end
		end

		{ is_valid: true }.extend(LookLikeJSON)
	end

	def self.page(params)

		if params["shopify_api_page"]["title"].blank?
			return {
				error_message: "Title can't be blank",
				is_valid: false
			}.extend(LookLikeJSON)
		end

		{ is_valid: true }.extend(LookLikeJSON)

	end

	def self.blog(params)

		if params["shopify_api_article"]["title"].blank?
			return {
				error_message: "Title can't be blank",
				is_valid: false
			}.extend(LookLikeJSON)
		end

		if params["shopify_api_article"]["blog_id"] == 'create_new_blog' and params["shopify_api_article"]["new_blog_title"].blank?
			return {
				error_message: "Blog title can't be blank",
				is_valid: false
			}.extend(LookLikeJSON)
		end

		{ is_valid: true }.extend(LookLikeJSON)

	end

	def self.custom_collection(params)

		if params["shopify_api_custom_collection"]["title"].blank?
			return {
				error_message: "Title can't be blank",
				is_valid: false
			}.extend(LookLikeJSON)
		end

		{ is_valid: true }.extend(LookLikeJSON)

	end

	def self.smart_collection(params)

		if params["shopify_api_smart_collection"]["title"].blank?
			return {
				error_message: "Title can't be blank",
				is_valid: false
			}.extend(LookLikeJSON)
		end

		unless params["shopify_api_smart_collection"]["collection_type"] === 'custom'
			for rule in params["shopify_api_smart_collection"]["rules"]
				if rule["condition"].blank?
					return {
						error_message: "Conditions are not valid",
						is_valid: false
					}.extend(LookLikeJSON)
				end

				if !rule["condition"].is_i? and (rule["column"] == 'variant_price' or rule["column"] == 'variant_compare_at_price' or rule["column"] == 'variant_weight' or rule["column"] == 'variant_inventory')
					return {
						error_message: "Conditions are not valid",
						is_valid: false
					}.extend(LookLikeJSON)
				end
			end
		end

		{ is_valid: true }.extend(LookLikeJSON)

	end
end