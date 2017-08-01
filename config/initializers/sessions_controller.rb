ShopifyApp::SessionsController.module_eval do
  def callback
    stored_return_address = return_address
    if response = request.env['omniauth.auth']
      shop_name = response.uid
      sess = ShopifyAPI::Session.new(shop_name, response['credentials']['token'])
      session[:shopify] = ShopifyApp::SessionRepository.store(sess)
      session[:shopify_domain] = shop_name
      flash[:notice] = "Logged in"
      redirect_url = false
      shopify_session do
        redirect_url = handle_recurring_application_charge
      end

      unless redirect_url
        if stored_return_address.include? "preview-window"
          redirect_url = 'https://' + shop_name 
        else 
          redirect_url = stored_return_address
        end
      end
      redirect_to redirect_url
    else
      flash[:error] = "Could not log in to Shopify store."
      redirect_to action: 'new'
    end
  end

  private

    def handle_recurring_application_charge
      puts Colorize.yellow(ShopifyAPI::RecurringApplicationCharge.current)
      unless ShopifyAPI::RecurringApplicationCharge.current
        recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new(
          name: "Beta Test",
          price: 0.01,
          test: true,
          trial_days: 9999)
        recurring_application_charge.return_url = Rails.env.production? ? "#{APP_URL}\/activatecharge" : "#{DEV_URL}\/activatecharge"

        if recurring_application_charge.save
          puts recurring_application_charge.confirmation_url
          @tokens[:confirmation_url] = recurring_application_charge.confirmation_url
          return recurring_application_charge.confirmation_url
        else
          puts Colorize.red(recurring_application_charge.errors)

          return false
        end
      end
    end
end
