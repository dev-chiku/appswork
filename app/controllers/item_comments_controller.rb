class ItemCommentsController < ApplicationController
  before_action :check_logined, only: [:create]

  # GET /item_comments
  # GET /item_comments.json
  def index
  end

  # GET /item_comments/1
  # GET /item_comments/1.json
  def show
  end

  # GET /item_comments/list/1
  def list
    cond = Hash.new

    # sqlセット
    sql = ""
    sql += "select itc.* "
    sql += "      ,ur.display_name user_name "
    sql += "      ,'' created_at_str "
    sql += "from item_comments itc "
    sql += "left join users ur "
    sql += "on ur.id = itc.create_user_id "
    sql += "where itc.item_id = :item_id "
    sql += "order by itc.created_at desc "

    cond[:item_id] = params[:id]

    # 検索してデータをjsonで返す
    itemComments = ItemComment.find_by_sql([sql, cond])

    # 日付フォーマット
    if !itemComments.nil?
      for comment in itemComments do
        comment[:created_at_str] = comment[:created_at].strftime("%Y/%m/%d %H:%M:%S")
      end
    end

    render :json => itemComments    
  end

  # GET /item_comments/new
  def new
  end

  # GET /item_comments/1/edit
  def edit
  end

  # POST /item_comments
  # POST /item_comments.json
  def create
    @item_comment = ItemComment.new(item_comment_params)
    
    set_create_user_id(@item_comment)

    ActiveRecord::Base.transaction do
      
      if !@item_comment.save
        render :json => @item_comment.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      # 追加データ取得
      sql = ""
      sql += "select itc.* "
      sql += "      ,ur.display_name user_name "
      sql += "      ,'' created_at_str "
      sql += "from item_comments itc "
      sql += "left join users ur "
      sql += "on ur.id = itc.create_user_id "
      sql += "where itc.id = :id "
      sql += "order by itc.created_at desc "
  
      cond = Hash.new
      cond[:id] = @item_comment[:id]
  
      # 検索してデータをjsonで返す
      itemComments = ItemComment.find_by_sql([sql, cond])
  
      for comment in itemComments do
        comment[:created_at_str] = comment[:created_at].strftime("%Y/%m/%d %H:%M:%S")
      end
      
      item = Item.find(@item_comment[:item_id]);

      # つながり追加処理
      if session[:user_id] != item[:create_user_id]
        connection = Connection.new()
        connection[:connect_kbn] = 15
        connection[:from_user_id] = session[:user_id]
        connection[:to_user_id] = item[:create_user_id]
        connection[:target_id] =  @item_comment[:item_id]
        set_create_user_id(connection)
        if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
          connection[:new_flg] = 1
        end
        if !connection.save
          render :json => connection.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        
        connection = Connection.new()
        connection[:connect_kbn] = 16
        connection[:from_user_id] = item[:create_user_id]
        connection[:to_user_id] = session[:user_id]
        connection[:target_id] =  @item_comment[:item_id]
        set_create_user_id(connection)
        if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
          connection[:new_flg] = 1
        end
        if !connection.save
          render :json => connection.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end        
      end

      render :json => itemComments[0]
    end
    
    return

  rescue => ex
    logger.fatal controller_name + " " + action_name + " " + ex.message
    errors = Hash.new
    errors[:error_message] = Array.new(1, "予期せぬエラーが発生しました。")
    render :json => errors, status: :unprocessable_entity
    
  end

  # PATCH/PUT /item_comments/1
  # PATCH/PUT /item_comments/1.json
  def update
  end

  # DELETE /item_comments/1
  # DELETE /item_comments/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_comment
      @item_comment = ItemComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_comment_params
      params.require(:item_comment).permit(:item_id, :comment, :create_user_id, :update_user_id)
    end
end
