class Shop < ActiveRecord::Base
  include ShopifyApp::Shop

  has_many :images
  has_many :authors

  def createScriptTag
		file = ApplicationController.new.render_to_string(:template => "home/dash_js.js", :layout => false)
    asset = ShopifyAPI::Asset.new
    asset.key = "assets/witty_easy_dash.js"
    asset.value = file

    if asset.save
      if ShopifyAPI::ScriptTag.first
  	    ShopifyAPI::ScriptTag.first.destroy
  	  end
   
      new_script_tag = ShopifyAPI::ScriptTag.new
      new_script_tag.event = 'onload'
      new_script_tag.src = asset.public_url
      if new_script_tag.save
        puts Colorize.cyan(asset.public_url)
        puts Colorize.green('created script tag')
      end
    end
  end

  def createTagTypeVendorQueryFiles
    search_tags = ShopifyAPI::Asset.new
    search_tags.key = "templates/search.easy_dash_tags.liquid"
    search_tags.value = ApplicationController.new.render_to_string(:template => "home/search_tags.liquid", :layout => false)
    if search_tags.save
      puts Colorize.green('Created Tags Query File')
    else
      puts Colorize.red(search_tags.errors)
    end

    search_types = ShopifyAPI::Asset.new
    search_types.key = "templates/search.easy_dash_types.liquid"
    search_types.value = ApplicationController.new.render_to_string(:template => "home/search_types.liquid", :layout => false)
    if search_types.save
      puts Colorize.green('Created Types Query File')
    else
      puts Colorize.red(search_types.errors)
    end

    search_vendors = ShopifyAPI::Asset.new
    search_vendors.key = "templates/search.easy_dash_vendors.liquid"
    search_vendors.value = ApplicationController.new.render_to_string(:template => "home/search_vendors.liquid", :layout => false)
    if search_vendors.save
      puts Colorize.green('Created Vendors Query File')
    else
      puts Colorize.red(search_vendors.errors)
    end
  end

  def createWebhook 
    webhook = ShopifyAPI::Webhook.find(:first, params: {topic: 'app/uninstalled'})

    if webhook
      webhook.destroy
      puts Colorize.red('webhook deleted')
    end

    webhook = ShopifyAPI::Webhook.new
    webhook.topic = 'app/uninstalled'
    webhook_address_url = Rails.env.production? ? APP_URL : 'https://c3a581b4.ngrok.io'
    webhook.address = webhook_address_url + '/app-uninstall'
    webhook.format = 'json'

    if webhook.save
      puts Colorize.green('created webhook')
    else
      puts Colorize.red(webhook.errors.messages)
    end  
  end

  def getShopData
    shopify_store_data = ShopifyAPI::Shop.current
    self.email = shopify_store_data.email
    self.save
  end

  def pingTheme
    themes = ShopifyAPI::Theme.all

    easy_dash_theme = false
    themes.each do |theme|
      if theme.name == "Easy Dash Images"
        easy_dash_theme = theme
      end
    end

    unless easy_dash_theme
      easy_dash_theme = ShopifyAPI::Theme.create(name: "Easy Dash Images")
    end

    easy_dash_theme
  end

  def generate_token
    self.front_end_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(front_end_token: random_token)
    end
    if self.save
      puts Colorize.green('Generated token')
    else
      puts Colorize.red('mistakes were made')
    end
    self.front_end_token
  end
end
