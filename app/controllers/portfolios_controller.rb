class PortfoliosController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def show
    @portfolio = Portfolio.find(params[:id])
    if current_user
      cookies_id = current_user.id * 100000 + @portfolio.id
      unless current_user == @portfolio.user || cookies.permanent.signed["#{cookies_id}"]
        cookies.permanent.signed["#{cookies_id}"] = SecureRandom.base64(12)
        REDIS.zincrby "portfolios/#{Date.current}", 1, @portfolio.id
      end
    end
    @progress = @portfolio.progresses.limit(1).order("created_at DESC").first
  end

  def new
    @portfolio = current_user.portfolios.build
    @portfolio.progresses.build(content: "最初の投稿です。")
  end

  def create
    @portfolio = current_user.portfolios.build(portfolio_params)
    if @portfolio.save
      redirect_to @portfolio, notice: t("flash.create", item: "ポートフォリオ")
    else
      flash.now[:alert] = t("flash.alert", matter: "ポートフォリオの作成")
      render "new"
    end
  end

  def edit
  end

  def update
    if @portfolio.update_attributes(portfolio_params)
      redirect_to @portfolio, notice: t("flash.update", item: "ポートフォリオ")
    else
      flash.now[:alert] = t("flash.alert", matter: "ポートフォリオの更新")
      render "edit"
    end
  end

  def destroy
    portfolio = @portfolio
    if @portfolio.destroy
      delete_redis(portfolio)
      redirect_to @portfolio.user, notice: t("flash.delete", item: "ポートフォリオ")
    else
      flash.now[:alert] = t("flash.alert", matter: "ポートフォリオの削除")
      redirect_root
    end
  end

  private
    def portfolio_params
      params.require(:portfolio).permit(
        :title,
        :content,
        :image,
        :web_url,
        :git_url,
        progresses_attributes: [ :content ]
      )
    end

    def correct_user
      @portfolio = current_user.portfolios.find_by(id: params[:id])
      if @portfolio.nil?
        case action_name
        when "edit"
          flash.now[:alert] = t("flash.get_alert", matter: "ページ")
        when "update"
          flash.now[:alert] = t("flash.alert", matter: "ポートフォリオの更新")
        when "destroy"
          flash.now[:alert] = t("flash.alert", matter: "ポートフォリオの削除")
        end
        redirect_root
      end
    end

    def delete_redis(portfolio)
      (portfolio.created_at.to_datetime..Date.tomorrow).each do |date|
        REDIS.zrem "portfolios/#{date.strftime("%Y-%m-%d")}", portfolio.id
      end
      REDIS.del "portfolios/total/#{portfolio.id}"
    end
end
