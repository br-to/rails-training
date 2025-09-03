class CommentsController < ApplicationController
  before_action :set_article
  before_action :set_comment, only: [:update, :destroy]

  # POST /articles/:article_id/comments
  def create
    @comment = @article.comments.new(comment_params)

    if @comment.save
      render json: @comment, status: :created, location: [@article, @comment]
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articles/:article_id/comments/:id
  def update
    @comment = @article.comments.find(params[:id])

    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/:article_id/comments/:id
  def destroy
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    head :no_content
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def set_comment
    @comment = @article.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :author)
  end
end
