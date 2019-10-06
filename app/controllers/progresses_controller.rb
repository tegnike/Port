class ProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_portfolio
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @progresses = @portfolio.progresses.order(created_at: :desc).page(params[:page])
  end

  def new
    @progress = @portfolio.progresses.build
  end

  def create
    @progress = @portfolio.progresses.new(progress_params)
    if @progress.save
      redirect_to @portfolio, notice: t("flash.create", item: "プログレス")
    else
      flash.now[:alert] = t("flash.alert", matter: "プログレスの作成")
      render "new"
    end
  end

  def edit
  end

  def update
    if @progress.update_attributes(progress_params)
      redirect_to portfolio_progresses_path(@portfolio), notice: t("flash.update", item: "プログレス")
    else
      flash.now[:alert] = t("flash.alert", matter: "プログレスの更新")
      render "edit"
    end
  end

  def destroy
    if @progress.destroy
      redirect_to portfolio_progresses_path(@portfolio), notice: t("flash.delete", item: "プログレス")
    else
      flash.now[:alert] = t("flash.alert", matter: "プログレスの削除")
      redirect_root
    end
  end

  private
    def get_portfolio
      @portfolio = Portfolio.find(params[:portfolio_id])
    end

    def progress_params
      params.require(:progress).permit(:content)
    end

    def correct_user
      @progress = @portfolio.progresses.find_by(id: params[:id])
      if @progress.nil?
        case action_name
        when "edit"
          flash.now[:alert] = t("flash.get_alert", matter: "ページ")
        when "update"
          flash.now[:alert] = t("flash.alert", matter: "プログレスの更新")
        when "destroy"
          flash.now[:alert] = t("flash.alert", matter: "プログレスの削除")
        end
        redirect_root
      end
    end
end
