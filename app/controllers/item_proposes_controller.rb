class ItemProposesController < ApplicationController
  before_action :check_logined, only: [:show, :create]

  # GET /item_proposes
  # GET /item_proposes.json
  def index
  end

  # GET /item_proposes/1
  # GET /item_proposes/1.json
  def show
    cond = Hash.new
    cond[:item_id] = params[:id]
    cond[:user_id] = session[:user_id]

    # sqlセット
    sql = ""
    sql += "select itp.* "
    sql += "      ,ifnull(nm_week_hour_kbn.name, '') week_hour_kbn_nm "
    sql += "      ,ifnull(nm_week_hour_period_kbn.name, '') week_hour_period_kbn_nm "
    sql += "from item_proposes itp "
    sql += "left join names nm_week_hour_kbn "
    sql += "on nm_week_hour_kbn.id = itp.week_hour_kbn "
    sql += "left join names nm_week_hour_period_kbn "
    sql += "on nm_week_hour_period_kbn.id = itp.week_hour_period_kbn "
    sql += "where itp.item_id = :item_id "
    sql += "and itp.create_user_id = :user_id "
    
    # 検索してデータをjsonで返す
    itemPropose = ItemPropose.find_by_sql([sql, cond])  
    if itemPropose.nil? || itemPropose.size == 0 
      render :json => ""
    else
      render :json => itemPropose[0]
    end
  end

  # GET /item_proposes/new
  def new
  end

  # GET /item_proposes/1/edit
  def edit
  end

  # POST /item_proposes
  # POST /item_proposes.json
  def create
    
    isErrorFlg = false
    
    item_propose_param = ItemPropose.new(item_propose_params)
    
    @item_propose = nil
    if !params[:id].blank?
      @item_propose = ItemPropose.find(params[:id])
    else
      @item_propose = item_propose_param
    end
    
    set_create_user_id(@item_propose)

    ActiveRecord::Base.transaction do
      # 提案対象アイテム取得
      item = Item.find(@item_propose[:item_id])

      if params[:id].blank?
        # 提案件数インクリメント
        if item[:propose_count].blank?
          item[:propose_count] = 0
        end
        item[:propose_count] = item[:propose_count] + 1
        item.save

        # 提案追加処理
        if !@item_propose.save
          render :json => @item_propose.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      else
        item_propose = ItemPropose.find(params[:id])
        if !item_propose[:ok_flg].blank? && item_propose[:ok_flg] == 1
          errors = Hash.new
          errors[:error_message] = Array.new(1, "すでに合意済みの提案です。")
          render :json => errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        
        # 提案更新処理
        if !@item_propose.update(item_propose_params)
          render :json => @item_propose.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end
      
      # メッセージ追加処理
      message = Message.new()
      message[:item_id] = @item_propose[:item_id]
      message[:parent_id] = 0
      message[:send_user_id] = session[:user_id]
      message[:receive_user_id] = item[:create_user_id]
      message[:title] = item[:title]
      message[:content] = @item_propose[:content]
      set_create_user_id(message)
      if !message.save
        render :json => message.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      
      # つながり追加処理
      connection = Connection.new()
      if params[:id].blank?
        connection[:connect_kbn] = 3
      else
        connection[:connect_kbn] = 9
      end
      connection[:from_user_id] = session[:user_id]
      connection[:to_user_id] = item[:create_user_id]
      connection[:target_id] =  @item_propose[:item_id]
      set_create_user_id(connection)
      if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
        connection[:new_flg] = 1
      end
      if !connection.save
        render :json => connection.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      connection = Connection.new()
      if params[:id].blank?
        connection[:connect_kbn] = 4
      else
        connection[:connect_kbn] = 10
      end
      connection[:from_user_id] = item[:create_user_id]
      connection[:to_user_id] = session[:user_id]
      connection[:target_id] =  @item_propose[:item_id]
      set_create_user_id(connection)
      if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
        connection[:new_flg] = 1
      end
      if !connection.save
        render :json => connection.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      
      fromUser = User.find(message[:send_user_id])
      toUser = User.find(message[:receive_user_id])
      
      # 通知追加
      notification = Notification.new()
      notification[:notification_kbn] = 1;
      notification[:target_id] = message[:id];
      notification[:user_id] = message[:receive_user_id];
      set_create_user_id(notification)
      if !notification.save
        render :json => notification.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      
      # メッセージ送信処理
      linkUrl = request.url.gsub("api/item_proposes", "")
      content = message[:content]
      if message[:content].length > 3
        content = message[:content][0, (message[:content].length - 3)] + "..."
      end
      
      @mail = PostMailer.notice_proposes(fromUser[:email], toUser[:email], fromUser[:display_name], toUser[:display_name], message[:title], content, linkUrl)
      @mail.deliver_now # if Rails.env.production?

      render :json => @item_propose
    end
    
    return

  rescue => ex
    logger.fatal controller_name + " " + action_name + " " + ex.message
    errors = Hash.new
    errors[:error_message] = Array.new(1, "予期せぬエラーが発生しました。")
    render :json => errors, status: :unprocessable_entity
    
  end

  # PATCH/PUT /item_proposes/1
  # PATCH/PUT /item_proposes/1.json
  def update
  end

  # DELETE /item_proposes/1
  # DELETE /item_proposes/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_propose
#      @item_propose = ItemPropose.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_propose_params
      params.require(:item_propose).permit(:item_id, :payment_kbn, :price, :noki, :hour_price, :week_hour_kbn, :week_hour_period_kbn, :content, :create_user_id, :update_user_id)
    end
end
