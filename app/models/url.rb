class Url < ActiveRecord::Base
   has_shortened_urls
   validates :name, presence: true
   validates :url_original, presence: true

   after_destroy :delete_short_url

   def delete_short_url
    self.shortened_urls.first.destroy
   end
end
