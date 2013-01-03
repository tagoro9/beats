class User < ActiveRecord::Base
	def self.create_with_omniauth(auth)
	  create! do |user|
	    user.provider = auth["provider"]
	    user.uid      = auth["uid"]
	    user.name     = auth['extra']['raw_info']["name"]
	    user.email    = auth['extra']['raw_info']['profile_image_url']
	  end
	end
end
