Beats.controllers :sound do
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

## Aqui se genera /sound/family
  get :family, :provides => :json do 
    families = []
    Sound.select(:family).uniq.each { |fam|
      families.push(fam.family)
    }
    JSON.generate(families)
  end


  get :samples, :with => :family, :provides => :json do
    samples = {}
    Sound.find_all_by_family(params[:family]).each { |sam|
      samples[sam.name] = sam.url
    }
    JSON.generate(samples)
  end

  get :show do
    
  end

  post :create do
    
  end

end
