class GenresController < InheritedResources::Base
  before_action :check_admin
  before_action :set_genre, only: [:show, :edit, :update, :destroy]


  def index
    @genres = Genre.all
  end


  def show
  end


  def new
    @genre = Genre.new
  end


  def edit
  end


  def create
    @genre = Genre.new(genre_params)

    #    @song.set_mime_type(params[:song][:song_file])
    respond_to do |format|
      if @genre.save
        format.html { redirect_to @genre, notice: 'Genre was successfully created.' }
        format.json { render action: 'show', status: :created, location: @song }
      else
        format.html { render action: 'new' }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @genre.update(genre_params)
        format.html { redirect_to @genre, notice: 'Genre was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @genre.destroy
    respond_to do |format|
      format.html { redirect_to genres_url }
      format.json { head :no_content }
    end
  end




  private
  # Use callbacks to share common setup or constraints between actions.
  def set_genre
    @genre = Genre.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def genre_params
    params.require(:genre).permit(:song_type)
  end

  protected 
    def check_admin
    if signed_in?
      unless current_user.is_admin?
        flash[:alert]=  'Only admins allowed!'
        redirect_to root_url
      end
    else
      # or you can use the authenticate_user! devise provides to only allow signed_in users
      flash[:alert]= 'Please sign in!'
      redirect_to root_url
    end
  end
end
