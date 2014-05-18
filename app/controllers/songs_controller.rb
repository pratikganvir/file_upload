class SongsController < InheritedResources::Base

  def new
    @song = Song.new
  end

  def edit
    @song = Song.find(params[:id])
  end

  def create
    @song = Song.new(allowed_params)
    if @song.save
      flash[:notice] = "Song created succesfully."
      redirect_to :@song
    else
      flash[:notice] = @song.errors.full_messages.join("<br/>").html_safe
      render "new"
    end
  end

  def allowed_params
    params.require(:song).permit(:artist_name,:title,:genere_nam,:duration,:price,:country)
  end
end
