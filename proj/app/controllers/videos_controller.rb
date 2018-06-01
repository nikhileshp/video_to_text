class VideosController < ApplicationController



protect_from_forgery prepend: true, with: :exception


require "google/cloud/speech"
require 'streamio-ffmpeg'
require 'fileutils'
require "sinatra"
require "google/cloud/storage"
require "date"
require 'uri'
require 'csv'
require "google/cloud/storage"

  before_action :set_video, only: [:show, :edit, :update, :destroy, :transcribe]

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
    @incomplete = Video.where(:status => 'incomplete' ) #Need to change 
    @complete = Video.where(:status => 'complete' )
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render :show, status: :created, location: @video }
      else
        format.html { render :new }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_url, notice: 'Video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def transcribe
    video_details = Video.find(params[:id])
    url = (video_details.file).to_s
    
    #Service Account Key and Project Name
    project_id = "referralyogi-contact-import" #previously ry-project-2
    bucket_name = "referralyogi" #previously ry-bucket-1
    key_file = "/mnt/hgfs/Ruby Day/Project Files/ReferralYogi Contact Import-7965e0852911.json" # Location of the Key file

    
    #Bucket Name and Name of the file being stored in the bucket

    storage_file_path = "audio_" + Time.now.strftime('%Y-%m-%d_%H-%M-%S') + ".wav"

    #Name of the file after it being converted from video
    audio_file_path = "/mnt/hgfs/Ruby Day/Project Files/audioconv_" + Time.now.strftime('%Y-%m-%d_%H-%M-%S') + ".wav"
    local_file_path   = audio_file_path

    #Video File being converted
    movie = FFMPEG::Movie.new(url) #Choose the video file that needs to be converted
    movie.transcode(audio_file_path, %w(-ac 1)) { |progress| puts progress } #-ac 1 converts it to mono

    #Initializing Variables speech and storage
    speech = Google::Cloud::Speech.new project: project_id, keyfile:key_file


    #Storing the file in cloud
    storage = Google::Cloud::Storage.new project: project_id, keyfile:key_file
    bucket  = storage.bucket bucket_name
    file = bucket.create_file local_file_path, storage_file_path
    puts "Uploaded #{file.name} into cloud \n\n"
    storage_path = "gs://" + bucket_name + "/" + storage_file_path #Storage Path for file

    #Transcription Audio Encoding plus operation parameters
    audio  = speech.audio storage_path, language: "en-US"
    operation = audio.process max_alternatives: 1, profanity_filter: true

    #Transcripting into text
    puts "Transcription Operation started\n"
    puts "Reading from #{storage_path} \n\n"
 
  operation.wait_until_done!

      textfile = "/mnt/hgfs/Ruby Day/Project Files/file_" + Time.now.strftime('%Y-%m-%d_%H-%M-%S') + ".txt"
      results = operation.results
      f = File.new(textfile, 'w')
      full = ""
      count = 0
      confidence_overall = 0.000000
      confidence = 0.000000
    if f
      results.each do |result|
       @chunk = @video.chunks.new(:chunk_type => "Partial",
                                 :chunk_content=> "#{result.transcript}",
                                 :confidence=> result.confidence.to_f)
       @chunk.save!

       full = full + "#{result.transcript}" + " "
       confidence_overall = confidence_overall + result.confidence.to_f
       count = count + 1
       @chunk.errors.full_messages
       

      end
    else
      puts "Unable to open file!"
    end
      confidence = confidence_overall/count
      @chunk = @video.chunks.new(:chunk_type => "Full",
                                 :chunk_content=> full,
                                 :confidence=> confidence.to_f)
      f.syswrite("Transcription: #{full}\n")
      f.syswrite("Confidence: #{confidence}\n\n")


      @chunk.save!
      @chunk.errors
    file.delete
    File.delete(local_file_path)
    bucket.create_file textfile,  "uploads" + "/#{video_details.id}/" + "#{video_details.name}" + ".txt"
    location_text = "https://storage.googleapis.com/" +  bucket_name + "uploads" + "/#{video_details.id}/" + "#{video_details.name}" + ".txt"
    puts "Transcription Operation Completed\n\n"

    f.close 
    

    @video.update_attribute(:status, "complete") # Status changes to complete 
    @video.update_attribute(:textfile, location_text)

    respond_to do |format|
      format.html { redirect_to  videos_url,notice: "The video #{video_details.name} was successfuly transcribed by Google Speech API"}
      format.json { head :no_content }
    end

end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params.require(:video).permit(:name, :file)
    end
end
