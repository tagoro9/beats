Beats.controllers :songs do

  before :create do
    authenticate()
  end


  get :create, :map => '/songs' do
    Song.create! do |song|
      song.title = "My title"
      song.valoration = 0
      song.music = "No music yet"
      song.user_id = @current_user.id
    end
  end

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

  
end
