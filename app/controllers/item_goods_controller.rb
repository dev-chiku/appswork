class ItemGoodsController < ApplicationController

  # GET /item_goods
  # GET /item_goods.json
  def index
  end

  # GET /item_goods/1
  # GET /item_goods/1.json
  def show
  end

  # GET /item_goods/new
  def new
  end

  # GET /item_goods/1/edit
  def edit
  end

  # POST /item_goods
  # POST /item_goods.json
  def create
  end

  # PATCH/PUT /item_goods/1
  # PATCH/PUT /item_goods/1.json
  def update
  end

  # DELETE /item_goods/1
  # DELETE /item_goods/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_good
      @item_good = ItemGood.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_good_params
      params.require(:item_good).permit(:item_id, :user_id, :create_user_id, :update_user_id)
    end
end
