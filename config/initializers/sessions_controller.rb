ShopifyApp::SessionsController.module_eval do
  def callback
  	# puts Colorize.red(return_address)
    if response = request.env['omniauth.auth']
      shop_name = response.uid
      sess = ShopifyAPI::Session.new(shop_name, response['credentials']['token'])
      session[:shopify] = ShopifyApp::SessionRepository.store(sess)
      session[:shopify_domain] = shop_name
      flash[:notice] = "Logged in"
      if return_address.include? "preview-window"
      	redirect_to return_address # dashboard_path
      else
	      redirect_to return_address
	    end
    else
      flash[:error] = "Could not log in to Shopify store."
      redirect_to action: 'new'
    end
  end
end
