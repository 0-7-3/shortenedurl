class ArticlesController < ApplicationController

  def new 
    @url = Url.new
  end

end
