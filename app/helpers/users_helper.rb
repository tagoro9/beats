# Helper methods defined here can be accessed in any controller or view in the application

Beats.helpers do

	def signed_in?
		return true if session['dj']
		return false
	end
  # def simple_helper_method
  #  ...
  # end
end
