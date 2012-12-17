Admin.controllers :sounds do

  get :index do
    @sounds = Sound.all
    render 'sounds/index'
  end

  get :new do
    @sound = Sound.new
    render 'sounds/new'
  end

  post :create do
    @sound = Sound.new(params[:sound])
    if @sound.save
      flash[:notice] = 'Sound was successfully created.'
      redirect url(:sounds, :edit, :id => @sound.id)
    else
      render 'sounds/new'
    end
  end

  get :edit, :with => :id do
    @sound = Sound.find(params[:id])
    render 'sounds/edit'
  end

  put :update, :with => :id do
    @sound = Sound.find(params[:id])
    if @sound.update_attributes(params[:sound])
      flash[:notice] = 'Sound was successfully updated.'
      redirect url(:sounds, :edit, :id => @sound.id)
    else
      render 'sounds/edit'
    end
  end

  delete :destroy, :with => :id do
    sound = Sound.find(params[:id])
    if sound.destroy
      flash[:notice] = 'Sound was successfully destroyed.'
    else
      flash[:error] = 'Unable to destroy Sound!'
    end
    redirect url(:sounds, :index)
  end
end
