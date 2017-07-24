ShopifyApp::SessionsController.module_eval do
  def callback
    stored_return_address = return_address
    if response = request.env['omniauth.auth']
      shop_name = response.uid
      sess = ShopifyAPI::Session.new(shop_name, response['credentials']['token'])
      session[:shopify] = ShopifyApp::SessionRepository.store(sess)
      session[:shopify_domain] = shop_name
      flash[:notice] = "Logged in"
      if stored_return_address.include? "preview-window"
      	redirect_to 'https://' + shop_name 
      else
	      redirect_to stored_return_address
	    end
    else
      flash[:error] = "Could not log in to Shopify store."
      redirect_to action: 'new'
    end
  end
end
