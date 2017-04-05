# via https://ecommerce.shopify.com/c/api-announcements/t/upcoming-change-in-api-limit-calculations-159710
#
# This automatically slows down requests to Shopify if we exceed their rate limit
# NOTE that we'll always be calling shopify in background threads such as sidekiq,
# so this should not impact users directly.
#
# This has been tested by hand, it seems to do the right thing, but has not been
# truly load tested at scale.
module ActiveResource
  class Connection
    SHOPIFY_SLEEP_TIME = 0.5

    def request_with_sleeper(*args, &block)
      if self === ShopifyAPI::Base.connection
        if ShopifyAPI::Base.connection.response && ShopifyAPI.credit_maxed?
          Rails.logger.info "Shopify rate limit credit maxed. Sleeping #{SHOPIFY_SLEEP_TIME}..."
          sleep(SHOPIFY_SLEEP_TIME)
        end
        begin
          request_without_sleeper(*args, &block)
        rescue ActiveResource::ConnectionError => ex
          if ex.response.code.to_s == '429'
            Rails.logger.info "Shopify returned 429 (Rate Limit Exceeded). Sleeping #{SHOPIFY_SLEEP_TIME}..."
            sleep(SHOPIFY_SLEEP_TIME)
            retry
          else
            raise ex
          end
        end
      else
        request_without_sleeper(*args, &block)
      end
    rescue ShopifyAPI::Limits::LimitUnavailable => limit_unavailable
      # Either Shopify API stopped sending the limit header, or we're in a stubby test
      request_without_sleeper(*args, &block)
    end

    alias_method_chain :request, :sleeper
  end
end