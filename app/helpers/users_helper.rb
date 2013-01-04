# Helper methods defined here can be accessed in any controller or view in the application

Beats.helpers do

	def signed_in?
		@current_user = User.find_by_uid(session['dj']) if session['dj']
		!@current_user.nil?
	end

	def sign_in(user)
		session['dj'] = user.uid
		@current_user = user
	end

	def sign_out
		@current_user = nil
		session.clear
	end

    def authenticate
      deny_access unless signed_in?
    end

	def deny_access
		halt redirect url('/')
	end


end
