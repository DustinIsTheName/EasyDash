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
end
