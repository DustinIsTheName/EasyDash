class Shop < ActiveRecord::Base
  include ShopifyApp::Shop

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

  def create_recurring_application_charge
    unless ShopifyAPI::RecurringApplicationCharge.current
      recurring_application_charge = ShopifyAPI::RecurringApplicationCharge.new(
              name: "Gift Basket Plan",
              price: 9.99,
              return_url: "https:\/\/#{APP_URL}\/activatecharge",
              test: true,
              trial_days: 7,
              capped_amount: 100,
              terms: "$0.99 for every order created")

      if recurring_application_charge.save
        @tokens[:confirmation_url] = recurring_application_charge.confirmation_url
        redirect recurring_application_charge.confirmation_url
      end
    end
  end
end
