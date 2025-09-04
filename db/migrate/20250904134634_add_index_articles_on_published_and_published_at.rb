class AddIndexArticlesOnPublishedAndPublishedAt < ActiveRecord::Migration[7.2]
  def change
    add_index :articles, [:published, :published_at], name: :index_articles_on_published_and_published_at
  end
end
