ShopifyApp::SessionsController.module_eval do

  def new
    session[:charge_type] = params[:charge_type] if params[:charge_type].present?
    authenticate if params[:shop].present?
  end

  def callback
    puts params
    stored_return_address = return_address
    if response = request.env['omniauth.auth']
      shop_name = response.uid
      sess = ShopifyAPI::Session.new(shop_name, response['credentials']['token'])
      session[:shopify] = ShopifyApp::SessionRepository.store(sess)
      session[:shopify_domain] = shop_name
      flash[:notice] = "Logged in"
      redirect_url = false
      shopify_session do
        if session[:charge_type]
          redirect_url = RecurringApplicationCharge.create(session[:charge_type])
          session.delete(:charge_type)
        else
          redirect_url = RecurringApplicationCharge.create
        end
        @shop = Shop.find_by_shopify_domain(session[:shopify_domain])
        @shop.createScriptTag
        @shop.createTagTypeVendorQueryFiles
        @shop.createWebhook
        @shop.getShopData
        front_end_token = @shop.generate_token
        cookies[:front_end_token] = {
          :value => front_end_token,
          :expires => 2.years.from_now
        }
      end
      session[:logged_in] = true
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
end
