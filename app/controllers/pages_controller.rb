class PagesController < ApplicationController
  def about
    @quote_return_to = "about"
    @breadcrumbs = [ crumb_root, crumb_current("Giới thiệu") ]
  end

  def contact
    @quote_return_to = "contact"
    @breadcrumbs = [ crumb_root, crumb_current("Liên hệ") ]
  end
end
