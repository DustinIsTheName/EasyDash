class UnembeddedController < ApplicationController
	before_action :login_again_if_different_shop
  around_filter :shopify_session
  layout 'application'

  def quick_select
  	@product_count = ShopifyAPI::Product.count
  	@article_count = ShopifyAPI::Article.count
  	@page_count = ShopifyAPI::Page.count
  	@collection_count = ShopifyAPI::CustomCollection.count + ShopifyAPI::SmartCollection.count

  	@products = ShopifyAPI::Product.find(:all, params: {limit: 250, fields: ['title', 'handle', 'id']})
  	@articles = ShopifyAPI::Article.find(:all, params: {limit: 250, fields: ['title', 'handle', 'id']})
  	@pages = ShopifyAPI::Page.find(:all, params: {limit: 250, fields: ['title', 'handle', 'id']})
  	@collections = []

		@cc = ShopifyAPI::CustomCollection.find(:all, params: {title: params[:q], :limit => 250, fields: ['title', 'handle', 'id']})
		@cc.each do |c|
		  @collections << c
		 end

		@sc = ShopifyAPI::SmartCollection.find(:all, params: {title: params[:q], :limit => 250, fields: ['title', 'handle', 'id']})
		@sc.each do |c|
		 @collections << c
		end

  end

end
