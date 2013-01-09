Beats.controllers :songs do

  #Get all songs
  get :index, :map => '/songs', :provides => :json do
    json_songs = "{"
    Song.find(:all).each {|song|
      json_songs << JSON.generate(song.as_json) 
    }
    json_songs << "}"
    json_songs
  end

  #Update a song
  put :update, :map => '/songs/:id', :provides => :json do 
    song = Song.find_by_id params[:id]
    if signed_in? && @current_user.id = song.user_id
      if song
        params[:song].each { |key,val|
          song[key] = val
        }
        song.save
      end
      JSON.generate(:success => song.id)    
    else
      JSON.generate(:error => "You are not the owner of this song")
    end
  end

  #Get a song
  get :get, :map => '/songs/:id', :provides => :json do
    song = Song.find_by_id(params[:id]).as_json
    song ? JSON.generate(song) : "{}"
  end

  #Create new song
  post :create, :map => '/songs', :provides => :json do
    if signed_in?
      newSong = Song.create! do |song|
        song.title = params[:song][:title]
        song.valoration = 0
        song.music = params[:song][:music]
        song.user_id = @current_user.id
      end
      JSON.generate(:success => newSong.id)
    else
      JSON.generate(:error => "You must be logged in to create a song")
    end
  end
  
end
