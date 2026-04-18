class HomeController < ApplicationController
  include HomePageData

  def index
    load_home_page_data
    @breadcrumbs = nil
  end
end
