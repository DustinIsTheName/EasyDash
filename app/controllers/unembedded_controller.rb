class UnembeddedController < ApplicationController
	before_action :login_again_if_different_shop
  around_filter :shopify_session
  layout 'application'

  def quick_select

  	@products = ShopifyAPI::Product.find(:all, params: {limit: 250})
  	@articles = ShopifyAPI::Article.find(:all, params: {limit: 250})
  	@pages = ShopifyAPI::Page.find(:all, params: {limit: 250})
  	@collections = []

		@cc = ShopifyAPI::CustomCollection.find(:all, params: {title: params[:q], :limit => 250})
		@cc.each do |c|
		  @collections << c
		 end

		@sc = ShopifyAPI::SmartCollection.find(:all, params: {title: params[:q], :limit => 250})
		@sc.each do |c|
		 @collections << c
		end

  end

end
