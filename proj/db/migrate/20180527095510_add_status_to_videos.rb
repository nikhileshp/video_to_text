class AddStatusToVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :videos, :status, :string, :default=>"Incomplete"
  end
end
