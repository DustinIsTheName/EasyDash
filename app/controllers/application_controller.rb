class ApplicationController < ActionController::Base
  include ShopifyApp::Controller
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	private

    def get_shop
      @shop = Shop.find_by_shopify_domain(@shop_session.url) if @shop_session
    end

    def store_cookies(all_cookies)
      cookie_hash = {}
      session[:iframe_cookies]&.split('; ')&.each do |c|
        split_cookie = c.split('=')
        cookie_hash[split_cookie[0]] = split_cookie[1]
      end

      old_cookies_array = Array.new
      all_cookies&.each { | cookie |
        cleaned_cookie = cookie.split('; ')[0]
        old_cookies_array.push(cleaned_cookie)
        split_cookie = cleaned_cookie.split('=')
        cookie_hash[split_cookie[0]] = split_cookie[1]
      }

      cookies_array = Array.new
      cookie_hash.each do |c, v|
        if c
          if v
            cookies_array.push(c + '=' + v)
          else
            cookies_array.push(c + '=')
          end
        end
      end

      cookies = cookies_array.join('; ')
      session[:iframe_cookies] = cookies
    end

end
