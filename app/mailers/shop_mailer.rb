class ShopMailer < ApplicationMailer

  def uninstall_email(shop)
    @shop = shop
    mail(to: @shop.email, subject: 'Thank you for using EasyDash')
  end

  def test
  	mail(to: 'dustin@wittycreative.com', subject: 'Woah! You just emailed yourself!')
  end

end