class SongsController < InheritedResources::Base

  before_filter :find_song , :only=>[:edit,:show]

  def index
    @songs= Song.all
  end


  def show

  end
  
  def new
    @song = Song.new
  end

  def edit
    
  end

  def create
    debugger
    @song = Song.new(allowed_params)
    if @song.save
      flash[:notice] = "Song created succesfully."
      debugger
      redirect_to @song 
    else
      flash[:notice] = @song.errors.full_messages.join("<br/>").html_safe
      render "new"
    end
  end

  protected

  def allowed_params
    params.require(:song).permit(:artist_name,:title,:genere_name,:duration,:price,:country,:song_image,:song_file)
  end

  def find_song
    @song = Song.find(params[:id])
  end
end
