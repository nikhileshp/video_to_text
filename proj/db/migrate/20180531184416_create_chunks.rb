class CreateChunks < ActiveRecord::Migration[5.2]
  def change
    create_table :chunks do |t|
      t.integer :vid_id, :null => false, :references => [:videos, :id]
      t.string :chunk_type
      t.text :chunk_content
      t.float :confidence

      t.timestamps
    end
  end
end
