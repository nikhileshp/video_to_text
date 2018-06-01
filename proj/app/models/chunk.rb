class Chunk < ApplicationRecord
  belongs_to :video, optional: true
end
