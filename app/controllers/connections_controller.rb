class ConnectionsController < ApplicationController
  before_action :check_logined, only: [:index]

  # GET /connections
  # GET /connections.json
  def index
    cond = Hash.new
    result = Hash.new
    cond[:user_id] = session[:user_id]

    # 今週データの取得 =========================================== 
    sql = ""
    sql += "select ifnull(cn1.cnt, 0) cn1_cnt, ifnull(cn2.cnt, 0) cn2_cnt, ifnull(cn3.cnt, 0) cn3_cnt, ifnull(cn4.cnt, 0) cn4_cnt, ifnull(cn5.cnt, 0) cn5_cnt, ifnull(cn6.cnt, 0) cn6_cnt, ifnull(cn7.cnt, 0) cn7_cnt "
    sql += "  from (select count(id) "
    sql += "          from connections cn "
    sql += "         where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "           and cn.to_user_id = :user_id "
    sql += "           and cn.new_flg = 1) cn_main "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and DAYOFWEEK( cn.created_at ) = 1 "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and cn.new_flg = :new_flg) cn1 "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and DAYOFWEEK( cn.created_at ) = 2 "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and cn.new_flg = :new_flg) cn2 "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and DAYOFWEEK( cn.created_at ) = 3 "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and cn.new_flg = :new_flg) cn3 "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and DAYOFWEEK( cn.created_at ) = 4 "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and cn.new_flg = :new_flg) cn4 "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and DAYOFWEEK( cn.created_at ) = 5 "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and cn.new_flg = :new_flg) cn5 "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and DAYOFWEEK( cn.created_at ) = 6 "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and cn.new_flg = :new_flg) cn6 "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and DAYOFWEEK( cn.created_at ) = 7 "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and cn.new_flg = :new_flg) cn7 "
    sql += "         on 1 = 1 "
    
    # 今週 棒グラフ 新しいつながり 用データ取得
    cond[:new_flg] = 1
    result[:this_week_bar_new_connect] = Connection.find_by_sql([sql, cond])
    
    # 今週 棒グラフ 再度のつながり 用データ取得
    cond[:new_flg] = 0
    result[:this_week_bar_re_connect] = Connection.find_by_sql([sql, cond])
    
    sql = ""
    sql += "select ifnull(cn_new.cnt, 0) cn_new_cnt, ifnull(cn_re.cnt, 0) cn_re_cnt "
    sql += "  from (select count(id) "
    sql += "          from connections cn "
    sql += "         where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "           and cn.to_user_id = :user_id) cn_main "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and new_flg = 1) cn_new "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and new_flg = 0) cn_re "
    sql += "         on 1 = 1 "

    # 今週 円グラフ 用データ取得
    result[:this_week_pie_connect] = Connection.find_by_sql([sql, cond])
    
    sql = ""
    sql += " select cn.* "
    sql += "       ,DATE_FORMAT(cn.created_at, '%Y/%m/%d %H:%i:%S') created_at_str "
    sql += "       ,ifnull(it.title, '') title "
    sql += "       ,ifnull(it.id, 0) item_id "
    sql += "       ,ur.id user_id "
    sql += "       ,ur.display_name user_name "
    sql += "       ,ifnull(ur.img_path, '/assets/person.jpg') img_path "
    sql += "   from connections cn "
    sql += "   left join items it "
    sql += "   on it.id = cn.target_id "
    sql += "   and cn.connect_kbn in (1,2,3,4,9,10,11,12,13,14,15,16) "
    sql += "   left join users ur "
    sql += "   on ur.id = cn.from_user_id "
    sql += " where cn.to_user_id = :user_id "
    sql += " and YEARWEEK( NOW() ) = YEARWEEK( cn.created_at ) "
    sql += " order by cn.created_at desc "

    # 今週 つながり一覧用データ取得
    result[:this_week_list_connect] = Connection.find_by_sql([sql, cond])    
    
    
    # 今月データの取得 =========================================== 
    sql = ""
    sql += "select DAY(cn.created_at) cn_day, count(cn.id) cn_cnt "
    sql += "  from connections cn "
    sql += " where MONTH( NOW() ) = MONTH( cn.created_at ) "
    sql += "   and cn.to_user_id = :user_id "
    sql += "   and cn.new_flg = :new_flg "
    sql += " order by DAY(cn.created_at) asc "
    
    # 今月 棒グラフ 新しいつながり 用データ取得
    cond[:new_flg] = 1
    result[:this_month_bar_new_connect] = Connection.find_by_sql([sql, cond])
    
    # 今月 棒グラフ 再度のつながり 用データ取得
    cond[:new_flg] = 0
    result[:this_month_bar_re_connect] = Connection.find_by_sql([sql, cond])
    
    sql = ""
    sql += "select cn_new.cnt cn_new_cnt, cn_re.cnt cn_re_cnt "
    sql += "  from (select count(id) "
    sql += "          from connections cn "
    sql += "         where MONTH( NOW() ) = MONTH( cn.created_at ) "
    sql += "           and cn.to_user_id = :user_id) cn_main "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where MONTH( NOW() ) = MONTH( cn.created_at ) "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and new_flg = 1) cn_new "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where MONTH( NOW() ) = MONTH( cn.created_at ) "
    sql += "               and cn.to_user_id = :user_id "
    sql += "               and new_flg = 0) cn_re "
    sql += "         on 1 = 1 "

    # 今月 円グラフ 用データ取得
    result[:this_month_pie_connect] = Connection.find_by_sql([sql, cond])
    
    sql = ""
    sql += " select cn.* "
    sql += "       ,DATE_FORMAT(cn.created_at, '%Y/%m/%d %H:%i:%S') created_at_str "
    sql += "       ,ifnull(it.title, '') title "
    sql += "       ,ifnull(it.id, 0) item_id "
    sql += "       ,ur.id user_id "
    sql += "       ,ur.display_name user_name "
    sql += "       ,ifnull(ur.img_path, '/assets/person.jpg') img_path "
    sql += "   from connections cn "
    sql += "   left join items it "
    sql += "   on it.id = cn.target_id "
    sql += "   and cn.connect_kbn in (1,2,3,4,9,10,11,12,13,14,15,16) "
    sql += "   left join users ur "
    sql += "   on ur.id = cn.from_user_id "
    sql += " where cn.to_user_id = :user_id "
    sql += " and MONTH( NOW() ) = MONTH( cn.created_at ) "
    sql += " order by cn.created_at desc "

    # 今月 つながり一覧用データ取得
    result[:this_month_list_connect] = Connection.find_by_sql([sql, cond])      
    
   
    # すべてのデータの取得 =========================================== 
    sql = ""
    sql += "select cn_new.cnt cn_new_cnt, cn_re.cnt cn_re_cnt "
    sql += "  from (select count(id) "
    sql += "          from connections cn "
    sql += "         where cn.to_user_id = :user_id) cn_main "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where cn.to_user_id = :user_id "
    sql += "               and new_flg = 1) cn_new "
    sql += "         on 1 = 1 "
    sql += " left join (select count(id) cnt "
    sql += "              from connections cn "
    sql += "             where cn.to_user_id = :user_id "
    sql += "               and new_flg = 0) cn_re "
    sql += "         on 1 = 1 "

    # すべて 円グラフ 用データ取得
    result[:this_all_pie_connect] = Connection.find_by_sql([sql, cond])
    
    sql = ""
    sql += " select cn.* "
    sql += "       ,DATE_FORMAT(cn.created_at, '%Y/%m/%d %H:%i:%S') created_at_str "
    sql += "       ,ifnull(it.title, '') title "
    sql += "       ,ifnull(it.id, 0) item_id "
    sql += "       ,ur.id user_id "
    sql += "       ,ur.display_name user_name "
    sql += "       ,ifnull(ur.img_path, '/assets/person.jpg') img_path "
    sql += "   from connections cn "
    sql += "   left join items it "
    sql += "   on it.id = cn.target_id "
    sql += "   and cn.connect_kbn in (1,2,3,4,9,10,11,12,13,14,15,16) "
    sql += "   left join users ur "
    sql += "   on ur.id = cn.from_user_id "
    sql += " where cn.to_user_id = :user_id "
    sql += " order by cn.created_at desc "

    # すべて つながり一覧用データ取得
    result[:this_all_list_connect] = Connection.find_by_sql([sql, cond])     
    
    render :json => result
  end

  # GET /connections/1
  # GET /connections/1.json
  def show
  end

  # GET /connections/new
  def new
  end

  # GET /connections/1/edit
  def edit
  end

  # POST /connections
  # POST /connections.json
  def create
  end

  # PATCH/PUT /connections/1
  # PATCH/PUT /connections/1.json
  def update
  end

  # DELETE /connections/1
  # DELETE /connections/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_connection
#      @connection = Connection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def connection_params
      params.require(:connection).permit(:connect_kbn, :from_user_id, :to_user_id, :target_id, :create_user_id, :update_user_id)
    end
end
