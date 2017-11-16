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
  end

  def activate_charge

    puts Colorize.magenta(params)
    recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.find(params['charge_id'])
    if recurring_application_charge.status == "accepted"
      recurring_application_charge.activate 
    else

      @shop = Shop.find_by_shopify_domain(@shop_session.url)

      access_token = @shop.shopify_token

      revoke_url = 'https://'+@shop_session.url+'/admin/api_permissions/current.json'
      headers = {
        'X-Shopify-Access-Token' => access_token,
        content_type: 'application/json',
        accept: 'application/json'
      }

      response = RestClient.delete(revoke_url, headers)
      puts response.code # 200 for success
      
      redirect_to 'http://'+@shop_session.url+'/admin/apps' and return
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
