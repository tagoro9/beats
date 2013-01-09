class User < ActiveRecord::Base

	has_many :songs

	def self.create_with_omniauth(auth)
	  create! do |user|
	    user.provider = auth["provider"]
	    user.uid      = auth["uid"]
	    user.name     = auth['extra']['raw_info']["name"]
	    user.email    = auth['info']['nickname']
	  end
	end
end
