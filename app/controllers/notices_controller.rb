class NoticesController < ApplicationController

  # GET /notices
  # GET /notices.json
  def index
  end

  # GET /notices/1
  # GET /notices/1.json
  def show
  end

  # GET /notices/list
  def list

    cond = Hash.new
    if session[:user_id].nil?
      cond[:user_id] = session[:user_id]
    else
      cond[:user_id] = -99999
    end

    # 通知タイトル一覧の取得
    sql = ""
    sql += "select ns.id "
    sql += "      ,ns.title "
    sql += "      ,ns.content "
    sql += "      ,'' AS created_at_str "
    sql += '      ,ns.created_at '
    sql += "      ,nt_msg.nt_count notification_inf_count "
    sql += "from notices ns "
    sql += "left join (select count(nt.user_id) nt_count, "
    sql += "                  nt.user_id, "
    sql += "                  nt.target_id "
    sql += "           from notifications nt "
    sql += "           where nt.user_id = :user_id "
    sql += "           and nt.notification_kbn = 2 "
    sql += "           group by nt.user_id "
    sql += "                   ,nt.target_id) nt_msg "
    sql += "on nt_msg.target_id = ns.id "
    sql += "order by ns.created_at desc "
    notices = Notice.find_by_sql([sql, cond])    
    
    if notices.nil? || notices.size == 0
      render :json => ""
      return;
    end
    
    for notice in notices do
      notice[:created_at_str] = notice[:created_at].strftime("%Y/%m/%d %H:%M:%S")
    end
    
    render :json => notices
  end

  # GET /notices/new
  def new
  end

  # GET /notices/1/edit
  def edit
  end

  # POST /notices
  # POST /notices.json
  def create
  end

  # PATCH/PUT /notices/1
  # PATCH/PUT /notices/1.json
  def update
  end

  # DELETE /notices/1
  # DELETE /notices/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notice
      @notice = Notice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notice_params
      params.require(:notice).permit(:title, :content, :create_user_id, :update_user_id)
    end
end
