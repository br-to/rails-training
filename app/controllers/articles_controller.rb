class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :update, :destroy]

  # GET /articles
  def index
    @articles = Article.visible

    render json: @articles
  end

  # GET /articles/:id
  def show
    render json: @article
  end

  # POST /articles
  def create
    @article = Article.create!(article_params)

    render json: @article, status: :created, location: @article
  end

  # PATCH/PUT /articles/:id
  def update
    if @article.update!(article_params)
      render json: @article
    end
  end

  # DELETE /articles/:id
  def destroy
    @article.destroy!
    head :no_content
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :published, :published_at)
  end
end
