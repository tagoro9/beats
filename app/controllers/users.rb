Beats.controllers :users do
  # get :index, :map => "/foo/bar" do
  #   session[:foo] = "bar"
  #   render 'index'
  # end

  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get "/example" do
  #   "Hello world!"
  # end

require 'json'

  get :login, :map => '/' do
    if signed_in?
      render 'users/login'
    else
      "No lo estoy"
  end

get :auth, :map => '/auth/:provider/callback' do
  auth    = request.env["omniauth.auth"]
  user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)  
  session['dj'] = user.uid
  redirect "http://" + request.env["HTTP_HOST"] + "/home"
end

  get :index, :map => "/home" do
    render 'users/user'
=begin    
    if signed_in?
      @user = User.find_by_uid session['dj']
      render 'users/user'
    else
      render 'users/login'
=end
  end

end
