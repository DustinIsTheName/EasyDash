module RecurringApplicationCharge
	def self.create(charge_type = 'default')

    unless ShopifyAPI::RecurringApplicationCharge.current or ShopifyAPI::Shop.current.myshopify_domain == "witty-creative.myshopify.com" or ShopifyAPI::Shop.current.plan_name == 'affiliate' or Rails.env == 'development' or Rails.env == 'test'

			case charge_type
			when 'extended_trial'
	      recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new(
	        name: "Extended Trial",
	        price: 4.99,
	        test: Rails.env.development? ? true : nil,
	        trial_days: 30)
			else
	      recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new(
	        name: "Standard",
	        price: 4.99,
	        test: Rails.env.development? ? true : nil,
	        trial_days: 14)
	    end

      recurring_application_charge.return_url = Rails.env.production? ? "#{APP_URL}\/activatecharge" : "#{DEV_URL}\/activatecharge"
      if recurring_application_charge.save
        puts recurring_application_charge.confirmation_url
        @tokens[:confirmation_url] = recurring_application_charge.confirmation_url
        return recurring_application_charge.confirmation_url
      else
        puts Colorize.red(recurring_application_charge.errors.messages)

        return false
      end

    end
	end

	def check_for_charge
		unless ShopifyAPI::RecurringApplicationCharge.current or ShopifyAPI::Shop.current.plan_name == 'affiliate' or Rails.env == 'development' or Rails.env == 'test'
			pending = ShopifyAPI::RecurringApplicationCharge.pending.first
			if pending
				puts pending.confirmation_url
				redirect_to pending.confirmation_url
			else
				redirect_url = RecurringApplicationCharge.create
				puts redirect_url
				redirect_to redirect_url
			end
		end
	end
end