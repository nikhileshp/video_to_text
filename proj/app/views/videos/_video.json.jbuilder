json.extract! video, :id, :name, :file, :created_at, :updated_at
json.url video_url(video, format: :json)
