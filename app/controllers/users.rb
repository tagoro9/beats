Beats.controllers :users do

  require 'json'

  before :index do
    authenticate()
  end


  get :login, :map => '/' do
      if signed_in?
        @songs = Song.find :all, :order => 'valoration DESC', :limit => 5
        render 'users/user'
      else
        render 'users/login'
      end
  end

  get :auth, :map => '/auth/:provider/callback' do
    auth    = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)  
    sign_in(user)
    redirect url('/home')
  end

  get :destroy, :map => '/logout' do
    sign_out()
    render 'users/login'
  end

  get :index, :map => "/home" do
    @songs = Song.find :all, :order => 'valoration DESC', :limit => 5
    render 'users/user'
  end

end
