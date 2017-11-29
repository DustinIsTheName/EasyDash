class ErrorsController < ApplicationController
  protect_from_forgery with: :null_session
	before_action :login_again_if_different_shop
  before_action :get_shop

  def not_found
  	puts Colorize.cyan('request.xhr?')
  	puts Colorize.cyan(request.xhr?)

  	if request.xhr?
  		puts Colorize.blue('LOOK HERE')

			resource_url = request.original_url.gsub(CURRENT_URL, '')
			puts Colorize.orange("https://#{@shop_session.url}#{resource_url}")

	    uri = URI.parse("https://#{@shop_session.url}#{resource_url}")
	    # uri = URI.parse("https://s-medio.myshopify.com/products/tee-shirt-enfant-jumeaux-monster-teitw34/?ediframe=true")
	    http = Net::HTTP.new(uri.host, uri.port)
	    http.use_ssl = true

	    headers = session[:iframe_cookies] ? { 'Cookie' => session[:iframe_cookies] } : {}
	    response = http.get(uri, headers)
	    store_cookies(response.get_fields('set-cookie'))

	    redirect_count = 0
	    while (response.code == "301" or response.code == "302") and redirect_count < 10
	      headers = session[:iframe_cookies] ? { 'Cookie' => session[:iframe_cookies] } : {}
	      if response['location'].include? 'https://' 
	        redirect_location = response['location'] 
	      else
	        redirect_location = "https://#{@shop_session.url}#{response['location']}"
	      end
	      response = http.get(URI.parse(redirect_location), headers)
	      store_cookies(response.get_fields('set-cookie'))
	      redirect_count += 1
	    end

  		render json: response.body
	  else
	  	render(:status => 404)
	  end
  end

end