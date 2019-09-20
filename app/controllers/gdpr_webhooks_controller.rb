class GdprWebhooksController < ApplicationController

  def customers_redact
    head :ok
  end

  def shop_redact
    puts params

    shop = Shop.find_by_shopify_domain params["shop_domain"]
    shop.destroy

    head :ok
  end

  def customers_data_request
    head :ok
  end

end
