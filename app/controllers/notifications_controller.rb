class NotificationsController < ApplicationController

  # GET /notifications
  # GET /notifications.json
  def index
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
  end
  
  def list
    
    if session[:user_id].blank?
      render :json => ""
      return
    end

    cond = Hash.new
    cond[:user_id] = session[:user_id]

    sql = ""
    sql += "select ifnull(nt_msg.nt_count, 0) notification_msg_count"
    sql += "      ,ifnull(nt_inf.nt_count, 0) notification_inf_count"
    sql += "  from users ur "
    sql += "  left join (select count(nt.id) nt_count, "
    sql += "                    nt.user_id  "
    sql += "             from notifications nt "
    sql += "             where nt.user_id = :user_id "
    sql += "             and nt.notification_kbn = 1 "
    sql += "             group by nt.user_id) nt_msg "
    sql += "  on nt_msg.user_id = ur.id "
    sql += "  left join (select count(nt.id) nt_count, "
    sql += "                    nt.user_id  "
    sql += "             from notifications nt "
    sql += "             where nt.user_id = :user_id "
    sql += "             and nt.notification_kbn = 2 "
    sql += "             group by nt.user_id) nt_inf "
    sql += "  on nt_inf.user_id = ur.id "
    sql += "  where ur.id = :user_id "
    
    # 検索
    users = User.find_by_sql([sql, cond])    
    
    render :json => users[0]

  end

  # GET /notifications/new
  def new
  end

  # GET /notifications/1/edit
  def edit
  end

  # POST /notifications
  # POST /notifications.json
  def create
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def delete
    
    cond = Hash.new
    cond[:id] = params[:id]
    cond[:kbn] = params[:kbn]
    cond[:user_id] = session[:user_id]

    ActiveRecord::Base.transaction do
      
      if params[:kbn].to_i == 1
        # メッセージ
        sql = ""
        sql += "select * "
        sql += "from messages "
        sql += "where (id = :id or parent_id = :id) "
        messages = Message.find_by_sql([sql, cond])  
        
        if messages.nil? || messages.size == 0
          render :json => ""
          return
        end
        
        for message in messages do
          cond[:id] = message[:id]

          sql = ""
          sql += "select * "
          sql += "from notifications "
          sql += "where target_id = :id "
          sql += "and user_id = :user_id "
          sql += "and notification_kbn = :kbn "
          notifications = Notification.find_by_sql([sql, cond])  
          
          if notifications.nil? || notifications.size == 0
            next
          end
          
          for notification in notifications do
            notification.destroy!
          end
        end        
        
      else
        # お知らせ
        sql = ""
        sql += "select * "
        sql += "from notifications "
        sql += "where target_id = :id "
        sql += "and user_id = :user_id "
        sql += "and notification_kbn = :kbn "
        notifications = Notification.find_by_sql([sql, cond])  
        
        if notifications.nil? || notifications.size == 0
          render :json => ""
          return
        end
        
        for notification in notifications do
          notification.destroy!
        end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      #@notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:notification_kbn, :target_id, :user_id, :create_user_id, :update_user_id)
    end
end
