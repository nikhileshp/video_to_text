class AddTextfileToVideos < ActiveRecord::Migration[5.2]
  def change
    add_column :videos, :textfile, :string
  end
end
