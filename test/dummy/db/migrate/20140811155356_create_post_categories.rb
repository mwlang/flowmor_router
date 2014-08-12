class CreatePostCategories < ActiveRecord::Migration
  def change
    create_table :post_categories do |t|
      t.string :title
      t.string :name

      t.timestamps
    end
  end
end
