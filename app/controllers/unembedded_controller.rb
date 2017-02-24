class UnembeddedController < ApplicationController
	before_action :login_again_if_different_shop
  around_filter :shopify_session
  layout 'application'

  def quick_select
  end

end
