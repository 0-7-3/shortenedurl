class Url < ActiveRecord::Base
   has_shortened_urls
   validates :name, presence: true
   validates :url_original, presence: true
end
