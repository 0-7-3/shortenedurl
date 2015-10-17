class UrlsController < ApplicationController
  before_action :find_url, only: [:destroy]
  def index
    @urls = Url.all
  end

  def new 
    @url = Url.new
  end

  def create
    @url = Url.new(url_params)
    if @url.save
      Shortener::ShortenedUrl.generate(@url.url_original, owner: @url)
      redirect_to urls_path, :flash => { :success => "Successfully Created" }
    else
      render 'new'
    end
  end

  def destroy
    @url.destroy
    redirect_to urls_path
  end

  private

  def find_url
    @url = Url.find(params[:id])
  end

  def url_params
    params.require(:url).permit(:url_original, :name, :no_of_access, :ip)
  end

end
