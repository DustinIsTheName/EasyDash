class Shop < ActiveRecord::Base
  include ShopifyApp::Shop

  def createScriptTag(file)

    asset = ShopifyAPI::Asset.new
    asset.key = "assets/witty_easy_dash.js"
    asset.value = file
    asset.save

    if ShopifyAPI::ScriptTag.first
	    ShopifyAPI::ScriptTag.first.destroy
	  end
 
    new_script_tag = ShopifyAPI::ScriptTag.new
    new_script_tag.event = 'onload'
    new_script_tag.src = asset.public_url
    new_script_tag.save
    puts Colorize.cyan(asset.public_url)
    puts Colorize.green('created script tag')

  end
end
