class ItemsController < ApplicationController
  before_action :check_logined, only: [:create]

  # GET /items
  # GET /items.json
  def index
    render :layout => false
  end

  # GET /items/1
  # GET /items/1.json
  def show
    
    # Itemデータ取得
    item = Item.find(params[:id])
    if item.nil? 
      errors = Hash.new
      errors[:error_message] = Array.new(1, "パラメーターが不正です。")
      render :json => errors, status: :unprocessable_entity
    end
    
    # 表示件数インクリメント処理　
    if item[:create_user_id] != session[:user_id]
      if item[:view_count].nil?
        item[:view_count] = 1
      else
        item[:view_count] = item[:view_count] + 1
      end
      
      if item[:preview_flg].nil? || item[:preview_flg] == 0
        item.save
      end
    end
    
    cond = Hash.new
    cond[:id] = params[:id]
    
    # sqlセット
    sql = ""
    sql += "select it.* "
    sql += "      ,case when ifnull(itf.id, 0) = 0 then 0 else 1 end own_favorite_flg "
    sql += "      ,ifnull(ur.display_name, '') user_name "
    sql += "      ,ifnull(nm_wk.id, '') work_kbn_id "
    sql += "      ,ifnull(nm_wk.name, '') work_kbn_nm "
    sql += "      ,ifnull(nm_wk_dt.id, '') work_kbn_detail_id "
    sql += "      ,ifnull(nm_wk_dt.name, '') work_kbn_detail_nm "
    sql += "      ,ifnull(nm_price_kbn.name, '') price_kbn_nm "
    sql += "      ,ifnull(nm_hour_price_kbn.name, '') hour_price_kbn_nm "
    sql += "      ,ifnull(nm_week_hour_kbn.name, '') week_hour_kbn_nm "
    sql += "      ,ifnull(nm_week_hour_period_kbn.name, '') week_hour_period_kbn_nm "
    sql += "      ,(case when it.limit_date is not null then datediff(it.limit_date, CURRENT_DATE()) else datediff(it.created_at, CURRENT_DATE()) end) + 1 limit_days "
    sql += "      ,null as proposes "
    sql += "from items it "
    sql += "left join item_favorites itf "
    sql += "on itf.item_id = it.id "
    
    if session[:user_id].blank? || session[:user_id] == 0
      sql += "and itf.create_user_id = -9999999 "
    else
      sql += "and itf.create_user_id = :item_favorite_user_id "
      cond[:item_favorite_user_id] = session[:user_id]
    end 

    sql += "left join names nm_wk_dt "
    sql += "on nm_wk_dt.id = it.work_kbn "
    sql += "left join names nm_wk "
    sql += "on nm_wk.id = nm_wk_dt.parent_id "
    sql += "left join users ur "
    sql += "on ur.id = it.create_user_id "
    sql += "left join names nm_price_kbn "
    sql += "on nm_price_kbn.id = it.price_kbn "
    sql += "left join names nm_hour_price_kbn "
    sql += "on nm_hour_price_kbn.id = it.hour_price_kbn "
    sql += "left join names nm_week_hour_kbn "
    sql += "on nm_week_hour_kbn.id = it.week_hour_kbn "
    sql += "left join names nm_week_hour_period_kbn "
    sql += "on nm_week_hour_period_kbn.id = it.week_hour_period_kbn "
    sql += "where it.id = :id "
    
    # 検索してデータをjsonで返す
    items = User.find_by_sql([sql, cond])    
    if items.nil? || items.size == 0 
      errors = Hash.new
      errors[:error_message] = Array.new(1, "パラメーターが不正です。")
      render :json => errors, status: :unprocessable_entity
    else
      result = Hash.new
      
      result[:owner_flg] = 0
      
      # 自身のItemデータの場合
      if !session[:user_id].nil? && session[:user_id] == items[0][:create_user_id]
        result[:owner_flg] = 1
        
        # 提案一覧の取得
        # sqlセット
        sql = ""
        sql += "select itp.* "
        sql += "      ,it.title "
        sql += "      ,ifnull(nm_payment.name, '') as payment_kbn_name "
        sql += "      ,ifnull(nm_week_hour.name, '') as week_hour_kbn_name "
        sql += "      ,ifnull(nm_week_hour_period.name, '') as week_hour_period_kbn_name "
        sql += "      ,ifnull(ur.id, 0) as user_id "
        sql += "      ,ifnull(ur.display_name, '') as user_name "
        sql += "      ,ifnull(mg.msg_id, 0) as msg_id "
        sql += "from item_proposes itp "
        sql += "inner join items it "
        sql += "on it.id = itp.item_id "
        sql += "left join names nm_payment "
        sql += "on nm_payment.name_kbn = 10 "
        sql += "and nm_payment.id = itp.payment_kbn "
        sql += "left join names nm_week_hour "
        sql += "on nm_week_hour.name_kbn = 12 "
        sql += "and nm_week_hour.id = itp.week_hour_kbn "
        sql += "left join names nm_week_hour_period "
        sql += "on nm_week_hour_period.name_kbn = 13 "
        sql += "and nm_week_hour_period.id = itp.week_hour_period_kbn "
        sql += "left join users ur "
        sql += "on ur.id = itp.create_user_id "
        sql += "left join (select max(id)  msg_id, send_user_id, item_id from messages group by send_user_id, item_id) mg "
        sql += "on mg.send_user_id = itp.create_user_id "
        sql += "and mg.item_id = itp.item_id "
        sql += "where itp.item_id = :item_id "
        sql += "order by itp.updated_at desc "
        
        # 検索
        cond[:item_id] = items[0][:id]
        itemProposes = ItemPropose.find_by_sql([sql, cond])
        if !itemProposes.nil? && itemProposes.size > 0
          items[0][:proposes] = itemProposes
        end      
      end
      
      # 自身以外のItemデータの場合
      if !session[:user_id].nil? && session[:user_id] != items[0][:create_user_id]
        # つながり追加処理
        connection = Connection.new()
        connection[:connect_kbn] = 1
        connection[:from_user_id] = session[:user_id]
        connection[:to_user_id] = items[0][:create_user_id]
        connection[:target_id] = items[0][:id]
        set_create_user_id(connection)
        if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
          connection[:new_flg] = 1
        end
        if !connection.save
          render :json => connection.errors, status: :unprocessable_entity
          return
        end
        
        connection = Connection.new()
        connection[:connect_kbn] = 2
        connection[:from_user_id] = items[0][:create_user_id]
        connection[:to_user_id] = session[:user_id]
        connection[:target_id] = items[0][:id]
        set_create_user_id(connection)
        if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
          connection[:new_flg] = 1
        end
        if !connection.save
          render :json => connection.errors, status: :unprocessable_entity
          return
        end
        
      end
      result[:item] = items[0];
      render :json => result
    end

  end

  # GET /items/list
  def list

    cond = Hash.new

    # sqlセット
    sql = ""
    sql += "select it.id "
    sql += "      ,it.title "
    sql += "      ,it.content "
    sql += "      ,it.payment_kbn "
    sql += "      ,ifnull(nm_payment_kbn.name, '') payment_kbn_name "
    sql += "      ,it.price "
    sql += "      ,it.price_kbn "
    sql += "      ,ifnull(nm_price_kbn.name, '') price_kbn_name "
    sql += "      ,it.hour_price_kbn "
    sql += "      ,ifnull(nm_hour_price_kbn.name, '') hour_price_kbn_name "
    sql += "      ,it.work_kbn "
    sql += "      ,ifnull(nm_work_kbn.name, '') work_kbn_name "
    sql += "      ,ifnull(nm_work_kbn.parent_id, 0) parent_work_kbn_id "
    sql += "      ,ifnull(nm_parent_work_kbn.name, '') parent_work_kbn_name "
    sql += "      ,ifnull(ur.id, '') user_id "
    sql += "      ,ifnull(ur.display_name, '') user_name "
    sql += "      ,it.propose_count "
    sql += "      ,it.view_count "
    sql += "      ,it.favorite_count "
    sql += "      ,it.limit_date "
    sql += "      ,(case when it.limit_date is not null then datediff(it.limit_date, CURRENT_DATE()) else datediff(it.created_at, CURRENT_DATE()) end) + 1 limit_days "
    
    sql += "from items it "
    sql += "left join users ur "
    sql += "on ur.id = it.create_user_id "
    sql += "left join names nm_work_kbn "
    sql += "on nm_work_kbn.id = it.work_kbn "
    sql += "left join names nm_parent_work_kbn "
    sql += "on nm_parent_work_kbn.id = nm_work_kbn.parent_id "
    sql += "left join names nm_payment_kbn "
    sql += "on nm_payment_kbn.id = it.payment_kbn "
    sql += "left join names nm_price_kbn "
    sql += "on nm_price_kbn.id = it.price_kbn "
    sql += "left join names nm_hour_price_kbn "
    sql += "on nm_hour_price_kbn.id = it.hour_price_kbn "

    if session[:user_id] && !session[:user_id].nil? && !params[:favorite_only_flg].blank? && params[:favorite_only_flg] == "true"
      sql += "inner join item_favorites itf "
      sql += "on itf.item_id = it.id "
      sql += "and itf.create_user_id = " + session[:user_id].to_s + " " 
    end
   
    sql += "where it.preview_flg = 0 "
    if !params[:exclude_end_flg].blank? && params[:exclude_end_flg] == "true"
      sql += "and (case when it.limit_date is not null then datediff(it.limit_date, CURRENT_DATE()) else datediff(it.created_at, CURRENT_DATE()) end) >= 0 "
    end  

    work_kbn_str = ""
    if !params[:work_kbn1].blank? && params[:work_kbn1] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "1"
    end  
    if !params[:work_kbn2].blank? && params[:work_kbn2] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "2"
    end  
    if !params[:work_kbn3].blank? && params[:work_kbn3] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "3"
    end  
    if !params[:work_kbn4].blank? && params[:work_kbn4] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "4"
    end
    if !params[:work_kbn11].blank? && params[:work_kbn11] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "11"
    end
    if !params[:work_kbn12].blank? && params[:work_kbn12] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "12"
    end
    if !params[:work_kbn13].blank? && params[:work_kbn13] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "13"
    end
    if !params[:work_kbn14].blank? && params[:work_kbn14] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "14"
    end
    if !params[:work_kbn15].blank? && params[:work_kbn15] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "15"
    end
    if !params[:work_kbn16].blank? && params[:work_kbn16] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "16"
    end
    if !params[:work_kbn21].blank? && params[:work_kbn21] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "21"
    end
    if !params[:work_kbn22].blank? && params[:work_kbn22] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "22"
    end
    if !params[:work_kbn23].blank? && params[:work_kbn23] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "23"
    end
    if !params[:work_kbn24].blank? && params[:work_kbn24] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "24"
    end
    if !params[:work_kbn25].blank? && params[:work_kbn25] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "25"
    end
    if !params[:work_kbn31].blank? && params[:work_kbn31] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "31"
    end
    if !params[:work_kbn32].blank? && params[:work_kbn32] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "32"
    end
    if !params[:work_kbn33].blank? && params[:work_kbn33] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "33"
    end
    if !params[:work_kbn41].blank? && params[:work_kbn41] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "41"
    end
    if !params[:work_kbn42].blank? && params[:work_kbn42] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "42"
    end
    if !params[:work_kbn43].blank? && params[:work_kbn43] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "43"
    end
    if !params[:work_kbn44].blank? && params[:work_kbn44] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "44"
    end
    if !params[:work_kbn51].blank? && params[:work_kbn51] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "51"
    end
    if !params[:work_kbn52].blank? && params[:work_kbn52] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "52"
    end
    if !params[:work_kbn53].blank? && params[:work_kbn53] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "53"
    end
    if !params[:work_kbn61].blank? && params[:work_kbn61] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "61"
    end
    if !params[:work_kbn62].blank? && params[:work_kbn62] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "62"
    end
    if !params[:work_kbn63].blank? && params[:work_kbn63] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "63"
    end
    if !params[:work_kbn64].blank? && params[:work_kbn64] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "64"
    end
    if !params[:work_kbn65].blank? && params[:work_kbn65] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "65"
    end
    if !params[:work_kbn66].blank? && params[:work_kbn66] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "66"
    end
    if !params[:work_kbn67].blank? && params[:work_kbn67] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "67"
    end
    if !params[:work_kbn68].blank? && params[:work_kbn68] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "68"
    end
    if !params[:work_kbn71].blank? && params[:work_kbn71] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "71"
    end
    if !params[:work_kbn72].blank? && params[:work_kbn72] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "72"
    end
    if !params[:work_kbn73].blank? && params[:work_kbn73] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "73"
    end
    if !params[:work_kbn74].blank? && params[:work_kbn74] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "74"
    end
    if !params[:work_kbn75].blank? && params[:work_kbn75] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "75"
    end
    if !params[:work_kbn76].blank? && params[:work_kbn76] == "true"
      if work_kbn_str != ""
        work_kbn_str += ","
      end 
      work_kbn_str += "76"
    end
    if !work_kbn_str.blank?
        sql += "and it.work_kbn in(:work_kbn_str) "
        cond[:work_kbn_str] = work_kbn_str.split(",")
    else
        sql += "and it.work_kbn = 99999 "
    end

    if !params[:hourPriceStart].blank? && params[:hourPriceStart] =~ /\A-?\d+(.\d+)?\Z/
      if params[:hourPriceStart].to_i <= 1000
        cond[:hour_price_kbn_start] = 131
      elsif params[:hourPriceStart].to_i <= 1500
        cond[:hour_price_kbn_start] = 132
      elsif params[:hourPriceStart].to_i <= 2000
        cond[:hour_price_kbn_start] = 133
      elsif params[:hourPriceStart].to_i <= 2500
        cond[:hour_price_kbn_start] = 134
      elsif params[:hourPriceStart].to_i <= 3000
        cond[:hour_price_kbn_start] = 135
      elsif params[:hourPriceStart].to_i <= 4000
        cond[:hour_price_kbn_start] = 136
      elsif params[:hourPriceStart].to_i <= 5000
        cond[:hour_price_kbn_start] = 137
      else
        cond[:hour_price_kbn_start] = 138
      end
      sql += "and it.hour_price_kbn >= :hour_price_kbn_start "
    end
    
    if !params[:hourPriceEnd].blank? && params[:hourPriceEnd] =~ /\A-?\d+(.\d+)?\Z/
      if params[:hourPriceEnd].to_i <= 1000
        cond[:hour_price_kbn_end] = 131
      elsif params[:hourPriceEnd].to_i <= 1500
        cond[:hour_price_kbn_end] = 132
      elsif params[:hourPriceEnd].to_i <= 2000
        cond[:hour_price_kbn_end] = 133
      elsif params[:hourPriceEnd].to_i <= 2500
        cond[:hour_price_kbn_end] = 134
      elsif params[:hourPriceEnd].to_i <= 3000
        cond[:hour_price_kbn_end] = 135
      elsif params[:hourPriceEnd].to_i <= 4000
        cond[:hour_price_kbn_end] = 136
      elsif params[:hourPriceEnd].to_i <= 5000
        cond[:hour_price_kbn_end] = 137
      else
        cond[:hour_price_kbn_end] = 138
      end 
      sql += "and it.hour_price_kbn <= :hour_price_kbn_end "
    end
    
    if !params[:projectPriceStart].blank? && params[:projectPriceStart] =~ /\A-?\d+(.\d+)?\Z/
      if params[:projectPriceStart].to_i <= 50000
        cond[:project_price_kbn_start] = 401
      elsif params[:projectPriceStart].to_i <= 100000
        cond[:project_price_kbn_start] = 402
      elsif params[:projectPriceStart].to_i <= 300000
        cond[:project_price_kbn_start] = 403
      elsif params[:projectPriceStart].to_i <= 500000
        cond[:project_price_kbn_start] = 404
      elsif params[:projectPriceStart].to_i <= 1000000
        cond[:project_price_kbn_start] = 405
      elsif params[:projectPriceStart].to_i <= 3000000
        cond[:project_price_kbn_start] = 406
      elsif params[:projectPriceStart].to_i <= 5000000
        cond[:project_price_kbn_start] = 407
      elsif params[:projectPriceStart].to_i <= 10000000
        cond[:project_price_kbn_start] = 408
      else
        cond[:project_price_kbn_start] = 409
      end 
      sql += "and it.price_kbn >= :project_price_kbn_start "
    end
    
    if !params[:projectPriceEnd].blank? && params[:projectPriceEnd] =~ /\A-?\d+(.\d+)?\Z/
      if params[:projectPriceEnd].to_i <= 50000
        cond[:project_price_kbn_end] = 401
      elsif params[:projectPriceEnd].to_i <= 100000
        cond[:project_price_kbn_end] = 402
      elsif params[:projectPriceEnd].to_i <= 300000
        cond[:project_price_kbn_end] = 403
      elsif params[:projectPriceEnd].to_i <= 500000
        cond[:project_price_kbn_end] = 404
      elsif params[:projectPriceEnd].to_i <= 1000000
        cond[:project_price_kbn_end] = 405
      elsif params[:projectPriceEnd].to_i <= 3000000
        cond[:project_price_kbn_end] = 406
      elsif params[:projectPriceEnd].to_i <= 5000000
        cond[:project_price_kbn_end] = 407
      elsif params[:projectPriceEnd].to_i <= 10000000
        cond[:project_price_kbn_end] = 408
      else
        cond[:project_price_kbn_end] = 409
      end 
      sql += "and it.price_kbn <= :project_price_kbn_end "
    end

    if !params[:payment_kbn].blank? && params[:payment_kbn] != "123"
      cond[:payment_kbn] = params[:payment_kbn]
      sql += "and it.payment_kbn = :payment_kbn "
    end

    if !params[:order_kbn].blank?
      if params[:order_kbn] == "411"
        sql += "order by it.created_at desc "
      elsif params[:order_kbn] == "412"
        sql += "order by case when it.payment_kbn = 122 then it.price_kbn else it.hour_price_kbn end desc "
      end
    end

    # 検索してデータをjsonで返す
    items = Item.find_by_sql([sql, cond])    
    render :json => items
  end

  # GET /items/new
  def new
  end

  # GET /items/1/edit
  def edit
  end

  # GET /items/main
#  def main
#    render :layout => nil
#  end

  # POST /items
  # POST /items.json
  def create
    
    @item = Item.new(item_params)
    set_create_user_id(@item)
    
    item = nil;
    if !@item[:preview_flg].nil? && @item[:preview_flg] == 1
      # 過去保存データの取得
      item = Item.find_by(["preview_flg = 1 and create_user_id = ?", session[:user_id]])
      
      # 過去保存データがあればそのデータを更新する
      if !item.nil? 
        @item = item
        item_params[:id] = item[:id]
        item_params[:create_user_id] = item[:create_user_id]
        item_params[:created_at] = item[:created_at]
      end
    end
    
    respond_to do |format|
      if item.nil?
        if params[:id].blank? || params[:id] == 0
          # 追加時
          if @item.save
            render :json => @item
          else
            render :json => @item.errors, status: :unprocessable_entity
          end
        else
          # 更新時
          @item = Item.find_by(["id = ?", params[:id]])
          set_update_user_id(@item)
          if @item.update(item_params)
            render :json => @item
          else
            render :json => @item.errors, status: :unprocessable_entity
          end
        end
      else
        if @item.update(item_params)
          render :json => @item
        else
          render :json => @item.errors, status: :unprocessable_entity
        end
      end
      return;
    end
    
  rescue => ex
    logger.fatal controller_name + " " + action_name + " " + ex.message
    errors = Hash.new
    errors[:error_message] = Array.new(1, "予期せぬエラーが発生しました。")
    render :json => errors, status: :unprocessable_entity
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
#      @item = Item.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:work_kbn, :payment_kbn, :price, :price_kbn, :noki, :hour_price_kbn, :week_hour_kbn, :week_hour_period_kbn, :limit_date, :title, :content, :img_path, :preview_flg, :create_user_id, :update_user_id)
    end
end
