class ItemFavoritesController < ApplicationController
  before_action :check_logined, only: [:create]

  # GET /item_favorites
  # GET /item_favorites.json
  def index
  end

  # GET /item_favorites/1
  # GET /item_favorites/1.json
  def show
  end

  # GET /item_favorites/new
  def new
  end

  # GET /item_favorites/1/edit
  def edit
  end

  # POST /item_favorites
  # POST /item_favorites.json
  def create
    item = Item.find(params[:item_id])
    if item[:favorite_count].blank?
      item[:favorite_count] = 0
    end

    ActiveRecord::Base.transaction do

      if params[:flg] == "0"
        # 追加処理
        @item_favorite = ItemFavorite.new()
        @item_favorite[:item_id] = params[:item_id]
        set_create_user_id(@item_favorite)
        
        if !@item_favorite.save
          render :json => @item_favorite.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        
        # お気に入り件数の更新
        item[:favorite_count] = item[:favorite_count] + 1
        item.save
        
      else
        # 削除処理
        @item_favorite = ItemFavorite.find_by(["item_id = ? and create_user_id = ?", params[:item_id], session[:user_id]])
        @item_favorite.destroy

        # お気に入り件数の更新
        item[:favorite_count] = item[:favorite_count] - 1
        item.save
      end
      
      # つながり追加処理
      connection = Connection.new()
      if params[:flg] == "0"
        connection[:connect_kbn] = 11
      else
        connection[:connect_kbn] = 13
      end
      connection[:from_user_id] = session[:user_id]
      connection[:to_user_id] = item[:create_user_id]
      connection[:target_id] =  @item_favorite[:item_id]
      set_create_user_id(connection)
      if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
        connection[:new_flg] = 1
      end
      if !connection.save
        render :json => connection.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      connection = Connection.new()
      if params[:flg] == "0"
        connection[:connect_kbn] = 12
      else
        connection[:connect_kbn] = 14
      end
      connection[:from_user_id] = item[:create_user_id]
      connection[:to_user_id] = session[:user_id]
      connection[:target_id] =  @item_favorite[:item_id]
      set_create_user_id(connection)
      if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
        connection[:new_flg] = 1
      end
      if !connection.save
        render :json => connection.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end      
      
      render :json => ""
    end
    
    return

  rescue => ex
    logger.fatal controller_name + " " + action_name + " " + ex.message
    errors = Hash.new
    errors[:error_message] = Array.new(1, "予期せぬエラーが発生しました。")
    render :json => errors, status: :unprocessable_entity
    
  end

  # PATCH/PUT /item_favorites/1
  # PATCH/PUT /item_favorites/1.json
  def update
  end

  # DELETE /item_favorites/1
  # DELETE /item_favorites/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_favorite
      @item_favorite = ItemFavorite.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_favorite_params
      params.require(:item_favorite).permit(:item_id, :create_user_id, :update_user_id)
    end
end
