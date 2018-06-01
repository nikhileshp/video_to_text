json.extract! chunk, :id, :vid_id, :chunk_type, :chunk_content, :confidence, :created_at, :updated_at
json.url chunk_url(chunk, format: :json)
