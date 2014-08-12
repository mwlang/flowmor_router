class CreateNewsArticles < ActiveRecord::Migration
  def change
    create_table :news_articles do |t|
      t.string :caption
      t.string :slug

      t.timestamps
    end
  end
end
