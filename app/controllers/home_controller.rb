class HomeController < AuthenticatedController
	# protect_from_forgery except: :index

  def index
    @shop = Shop.find_by_shopify_domain(@shop_session.url)

    cookies[:permanent_domain] = {
      :value => "#{@shop_session.url}",
      :expires => 2.years.from_now
    }

    unless @shop.front_end_token
      @shop.generate_token
    end

    cookies[:front_end_token] = {
      :value => @shop.front_end_token,
      :expires => 2.years.from_now
    }

    # if session[:logged_in] == true
    #   # puts Colorize.green('logged_in')
    #   session.delete :logged_in
    #   @logged_in = true
    # end
  end

  def activate_charge

    puts Colorize.magenta(params)
    recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.find(params['charge_id'])
    if recurring_application_charge.status == "accepted"
      recurring_application_charge.activate 
    else 
      redirect_to root_path
    end

    redirect_to root_path
  end

  def sync_store
    @shop = Shop.find_by_shopify_domain(@shop_session.url)
    @shop.createScriptTag
    @shop.createTagTypeVendorQueryFiles
    @shop.createWebhook
    @shop.getShopData

    render json: {success: true}
  end

end
