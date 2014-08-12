class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.integer :category_id
      t.string :name

      t.timestamps
    end
  end
end
