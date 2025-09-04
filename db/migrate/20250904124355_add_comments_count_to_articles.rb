class AddCommentsCountToArticles < ActiveRecord::Migration[7.2]
  def up
    add_column :articles, :comments_count, :integer, default: 0, null: false
    execute <<~SQL
      UPDATE articles
      SET comments_count = sub.cnt
      FROM (
        SELECT article_id, COUNT(*) AS cnt
        FROM comments
        GROUP BY article_id
      ) AS sub
      WHERE sub.article_id = articles.id;
    SQL
  end

  def down
    remove_column :articles, :comments_count
  end
end
