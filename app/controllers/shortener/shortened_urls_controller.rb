class Shortener::ShortenedUrlsController < ActionController::Base

  # find the real link for the shortened link key and redirect
  def show

    # only use the leading valid characters
    token = /^([#{Shortener.key_chars.join}]*).*/.match(params[:id])[1]

    # pull the link out of the db
    sl = ::Shortener::ShortenedUrl.unexpired.where(unique_key: token).first
    

    if sl
      if check_access_limit(sl)
        if check_ip(sl)
        # don't want to wait for the increment to happen, make it snappy!
        # this is the place to enhance the metrics captured
        # for the system. You could log the request origin
        # browser type, ip address etc.
        Thread.new do
          sl.increment!(:use_count)
          ActiveRecord::Base.connection.close
        end

        params.except! *[:id, :action, :controller]
        url = sl.url

        if params.present?
          uri = URI.parse(sl.url)
          existing_params = Rack::Utils.parse_nested_query(uri.query)
          merged_params   = existing_params.merge(params)
          uri.query       = merged_params.to_query
          url             = uri.to_s
        end

        # do a 301 redirect to the destination url
        reduce_limit(sl)
        redirect_to url, status: :moved_permanently
      end
    end
    else
      # if we don't find the shortened link, redirect to the root
      # make this configurable in future versions
      redirect_to Shortener.default_redirect
    end
  end

  private


  def check_access_limit(url)
    limit = Url.find(url.owner_id).try(:no_of_access)
    if limit && limit <= 0 
      redirect_to urls_path, :flash => { :success => "Reach Maximum Limit Of Access" }
      return false
    else
      return true
    end
  end

  def reduce_limit(url)
    limit = Url.find(url.owner_id)
    total = limit.no_of_access ? limit.no_of_access : 0 
    limit.update_columns(no_of_access: total - 1)
    return true
  end

  def check_ip(url)

    ip = Url.find(url.owner_id).try(:ip)
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    puts ip
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts request.remote_ip

    if ip && ip == request.remote_ip
      return true
    else
      redirect_to urls_path, :flash => { :success => "You dont have access this url by this ip" }
      return false
    end
  end
end
