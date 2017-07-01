class Validate
	def self.product(params)

		if params["shopify_api_product"]["title"].blank?
			return {
				error_message: "Title can't be blank",
				is_valid: false
			}.extend(LookLikeJSON)
		end

		{ is_valid: true }.extend(LookLikeJSON)
	end

	def self.variant(params, variant)

    if params[:id] == 'new'
      v = params["variants"]
    else
      v = params["variants"][variant.id.to_s]
    end

    for i in 0..2
	    if params["options"][i] and v["option#{i+1}"].blank?
				return {
					error_message: "You need to add option values for #{params["options"][i]}",
					is_valid: false
				}.extend(LookLikeJSON)
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
				puts harmonized_system_code["value"]
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
end