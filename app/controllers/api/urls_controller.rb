class Api::UrlsController < ApplicationController

  def shortener_url
    if params[:url].present?
      url = Url.new
      url.url_original = params[:url]
      url.name = 'Api'
      url.save!
      @data = Shortener::ShortenedUrl.generate(params[:url], owner: url)
    end
  end

end
