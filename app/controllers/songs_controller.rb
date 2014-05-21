class SongsController < ApplicationController
  before_action :check_admin, only: [:new,:create,:edit,:update]
  before_action :set_song, only: [:show, :edit, :update, :destroy]

  # GET /songs
  # GET /songs.json
  def index
    @songs = Song.all
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    @url = "/assets/songs/cut_songs/#{@song.song_file_file_name}"
  end

  # GET /songs/new
  def new
    @song = Song.new
  end

  # GET /songs/1/edit
  def edit
  end

  # POST /songs
  # POST /songs.json
  def create
    @song = Song.new(song_params)
    @song.set_default_played_song
    #    @song.set_mime_type(params[:song][:song_file])
    respond_to do |format|
      if @song.save
        input_file_path = "public/assets/songs/file/#{@song.id}/original/#{@song.song_file_file_name}"
        Song.cut_song_to_30_sec(input_file_path,@song.song_file_file_name)
        format.html { redirect_to @song, notice: 'Music was successfully created.' }
        format.json { render action: 'show', status: :created, location: @song }
      else
        format.html { render action: 'new' }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /songs/1
  # PATCH/PUT /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        input_file_path = "public/assets/songs/file/#{@song.id}/original/#{@song.song_file_file_name}"
        Song.cut_song_to_30_sec(input_file_path,@song.song_file_file_name)
        format.html { redirect_to @song, notice: 'Music was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song.destroy
    respond_to do |format|
      format.html { redirect_to songs_url }
      format.json { head :no_content }
    end
  end


  def get_30_seconds_song
    @song = Song.find(2)
    @url = "/assets/songs/cut_songs/#{@song.song_file_file_name}"
    respond_to do |format|
      format.html { redirect_to songs_url}
      format.json {render :json=> {:url=>@url , :song=>@song, :status=>200 }}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_song
    @song = Song.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def song_params
    params.require(:song).permit(:artist_name, :title, :genre_id, :duration, :price, :country, :song_image, :song_file)
  end

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
