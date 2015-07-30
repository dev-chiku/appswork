class MessagesController < ApplicationController
  before_action :check_logined, only: [:list, :create, :propose]

  # GET /messages/list
  def list

    cond = Hash.new
    cond[:user_id] = session[:user_id]

    # メッセージタイトル一覧の取得
    sql = ""
    sql += "select ms.id "
    sql += "      ,ms.title "
    sql += "      ,ms.content "
    sql += "      ,'' AS created_at_str "
    sql += '      ,ms.item_id '
    sql += '      ,ms.send_user_id '
    sql += '      ,ms.receive_user_id '
    sql += '      ,ms.created_at '
    sql += "      ,ur.id user_id "
    sql += "      ,ur.display_name user_name "
    sql += "      ,ur_send.id send_user_id "
    sql += "      ,ur_send.display_name send_user_name "
    sql += "      ,nt_msg.nt_count notification_msg_count"
    sql += "      ,null details "
    sql += "from messages ms "
    sql += "inner join users ur "
    sql += "on ur.id = ms.receive_user_id "
    sql += "inner join users ur_send "
    sql += "on ur_send.id = ms.send_user_id "
    sql += "left join (select count(nt.id) nt_count, "
    sql += "                  nt.user_id, "
    sql += "                  case when ms.parent_id = 0 then ms.id else ms.parent_id end target_id "
    sql += "           from notifications nt "
    sql += "           inner join messages ms "
    sql += "           on nt.target_id = ms.id "
    sql += "           where nt.user_id = :user_id "
    sql += "           and nt.notification_kbn = 1 "
    sql += "           group by nt.user_id "
    sql += "                   ,case when ms.parent_id = 0 then ms.id else ms.parent_id end) nt_msg "
    sql += "on nt_msg.user_id = :user_id "
    sql += "and nt_msg.target_id = ms.id "
    sql += "where ms.parent_id = 0 "
    sql += "and (ms.send_user_id = :user_id or ms.receive_user_id = :user_id) "
    sql += "order by ms.created_at desc "
    messages = Message.find_by_sql([sql, cond])    
    
    if messages.nil? || messages.size == 0
      render :json => ""
      return;
    end
    
    for message in messages do
      
      if session[:user_id] == message[:user_id]
        message[:user_id] = message[:send_user_id]
        message[:user_name] = message[:send_user_name]
      end
      
      # メッセージ詳細一覧の取得
      sql = ""
      sql += "select ms.id "
      sql += "      ,ms.parent_id "
      sql += "      ,ms.title "
      sql += "      ,ms.content "
      sql += "      ,'' AS created_at_str "
      sql += '      ,ms.item_id '
      sql += '      ,ms.send_user_id '
      sql += '      ,ms.receive_user_id '
      sql += '      ,ms.created_at '
      sql += "      ,ur.id user_id"
      sql += "      ,ur.display_name user_name "
      sql += "      ,null details "
      sql += "from messages ms "
      sql += "left join users ur "
      sql += "on ur.id = ms.send_user_id "
      sql += "where (ms.parent_id = :parent_id or ms.id = :parent_id) "
      sql += "and (ms.send_user_id = :user_id or ms.receive_user_id = :user_id) "
      sql += "order by ms.created_at desc "
  
      cond[:parent_id] = message[:id]

      message[:created_at_str] = message[:created_at].strftime("%Y/%m/%d %H:%M:%S")

      details = Message.find_by_sql([sql, cond])  
      
      if !details.nil? && details.size > 0
        for detail in details do
          detail[:created_at_str] = detail[:created_at].strftime("%Y/%m/%d %H:%M:%S")
        end  
      end

      message[:details] = details;

    end
    
    render :json => messages
  end
  
  # POST /messages
  # POST /messages.json
  def create
    cond = Hash.new
    
    @message = Message.new(message_params)
    set_create_user_id(@message)
    
    ActiveRecord::Base.transaction do
      if params[:id].blank? || params[:id] == 0
        # 追加時
        if !@message.save
          render :json => @message.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        
        # 通知追加
        notification = Notification.new()
        notification[:notification_kbn] = 1;
        notification[:target_id] = @message[:id];
        notification[:user_id] = @message[:receive_user_id];
        set_create_user_id(notification)
        if !notification.save
          render :json => notification.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        
        # つながり追加
        connection = Connection.new()
        connection[:connect_kbn] = 5
        connection[:from_user_id] = @message[:send_user_id]
        connection[:to_user_id] = @message[:receive_user_id]
        connection[:target_id] =  @message[:id]
        set_create_user_id(connection)
        if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
          connection[:new_flg] = 1
        end
        if !connection.save
          render :json => connection.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end

        connection = Connection.new()
        connection[:connect_kbn] = 6
        connection[:from_user_id] = @message[:receive_user_id]
        connection[:to_user_id] = @message[:send_user_id]
        connection[:target_id] =  @message[:id]
        set_create_user_id(connection)
        if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
          connection[:new_flg] = 1
        end
        if !connection.save
          render :json => connection.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        
        # メッセージ送信処理
        fromUser = User.find(@message[:send_user_id])
        toUser = User.find(@message[:receive_user_id])

        linkUrl = request.url.gsub("api/messages", "") + "message/target/"
        if @message[:parent_id].nil? || @message[:parent_id] == 0
          linkUrl = linkUrl + @message[:id].to_s
        else
          linkUrl = linkUrl + @message[:parent_id].to_s
        end
        content = @message[:content]
        if @message[:content].length > 3
          content = @message[:content][0, (@message[:content].length - 3)] + "..."
        end
        
        @mail = PostMailer.notice_message(fromUser[:email], toUser[:email], fromUser[:display_name], toUser[:display_name], content, linkUrl)
        @mail.deliver_now # if Rails.env.production?
        
        # メッセージタイトル一覧の取得
        sql = ""
        sql += "select ms.id "
        sql += "      ,ms.parent_id "
        sql += "      ,ms.title "
        sql += "      ,ms.content "
        sql += "      ,'' AS created_at_str "
        sql += '      ,ms.created_at '
        sql += '      ,ms.item_id '
        sql += '      ,ms.send_user_id '
        sql += '      ,ms.receive_user_id '
        sql += "      ,ur.id user_id "
        sql += "      ,ur.display_name user_name "
        sql += "      ,null details "
        sql += "from messages ms "
        sql += "left join users ur "

        if !params[:parent_id].blank? && params[:parent_id] != 0
          sql += "on ur.id = ms.send_user_id "
        else
          sql += "on ur.id = ms.receive_user_id "
        end
        
        sql += "where ms.id = :id "

        sql += "order by ms.parent_id, ms.created_at "

        cond[:id] = @message[:id]
        messages = Message.find_by_sql([sql, cond])  
        messages[0][:created_at_str] = messages[0][:created_at].strftime("%Y/%m/%d %H:%M:%S")
        
        if !params[:parent_id].blank? && params[:parent_id] != 0
          render :json => messages[0]
          return 
        end
        
        # メッセージ詳細一覧の取得
        sql = ""
        sql += "select ms.id "
        sql += "      ,ms.parent_id "
        sql += "      ,ms.title "
        sql += "      ,ms.content "
        sql += "      ,'' AS created_at_str "
        sql += '      ,ms.item_id '
        sql += '      ,ms.send_user_id '
        sql += '      ,ms.receive_user_id '
        sql += '      ,ms.created_at '
        sql += "      ,ur.id user_id"
        sql += "      ,ur.display_name user_name "
        sql += "      ,null details "
        sql += "from messages ms "
        sql += "left join users ur "
        sql += "on ur.id = ms.send_user_id "
        sql += "where ms.id = :id "
        sql += "order by ms.parent_id, ms.created_at desc "
        details = Message.find_by_sql([sql, cond])  
        details[0][:created_at_str] = details[0][:created_at].strftime("%Y/%m/%d %H:%M:%S")
        messages[0][:details] = details
        render :json => messages[0]

      else
        # 更新時
        @message = Message.find_by(["id = ?", params[:id]])
        set_update_user_id(@message)
        if !@message.update(message_params)
          render :json => @message.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
        
        sql = ""
        sql += "select * "
        sql += "from notifications "
        sql += "where target_id = :id "
        sql += "and user_id = :user_id "
        sql += "and notification_kbn = 1 "
        cond[:id] = @message[:id]
        cond[:user_id] = @message[:receive_user_id]
        notifications = Notification.find_by_sql([sql, cond])  
        if notifications.nil? || notifications.size == 0
          # 通知追加
          notification = Notification.new()
          notification[:notification_kbn] = 1;
          notification[:target_id] = @message[:id];
          notification[:user_id] = @message[:receive_user_id];
          set_create_user_id(notification)
          if !notification.save
            render :json => notification.errors, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
        
        # メッセージ送信処理
        fromUser = User.find(@message[:send_user_id])
        toUser = User.find(@message[:receive_user_id])

        linkUrl = request.url.gsub("api/messages", "") + "message/target/"
        if @message[:parent_id].nil? || @message[:parent_id] == 0
          linkUrl = linkUrl + @message[:id].to_s
        else
          linkUrl = linkUrl + @message[:parent_id].to_s
        end
        content = @message[:content]
        if @message[:content].length > 3
          content = @message[:content][0, (@message[:content].length - 3)] + "..."
        end
        
        @mail = PostMailer.notice_message(fromUser[:email], toUser[:email], fromUser[:display_name], toUser[:display_name], content, linkUrl)
        @mail.deliver_now # if Rails.env.production?
        
        render :json => @message

      end
      
    end

    return;      
    
  rescue => ex
    logger.fatal controller_name + " " + action_name + " " + ex.message
    errors = Hash.new
    errors[:error_message] = Array.new(1, "予期せぬエラーが発生しました。")
    render :json => errors, status: :unprocessable_entity
  end

  # POST /messages/propose
  def propose
    cond = Hash.new
    
    @message = Message.new(message_params)
    set_create_user_id(@message)
    
    ActiveRecord::Base.transaction do
      # 親ID取得
      message = Message.find_by(["item_id = ? and parent_id = 0 and send_user_id = ? ", @message[:item_id], @message[:receive_user_id]])
      @message[:parent_id] = message[:id]

      @message[:send_user_id] = session[:user_id]
      
      # 追加時
      if !@message.save
        render :json => @message.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      # 提案更新
      itemPropose = ItemPropose.find_by(["item_id = ? and create_user_id = ?", @message[:item_id], @message[:receive_user_id]])
      itemPropose[:ok_flg] = 1
      if !itemPropose.save
        render :json => itemPropose.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      
      # 通知追加
      notification = Notification.new()
      notification[:notification_kbn] = 1;
      notification[:target_id] = @message[:id];
      notification[:user_id] = @message[:receive_user_id];
      set_create_user_id(notification)
      if !notification.save
        render :json => notification.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      
      # つながり追加
      connection = Connection.new()
      connection[:connect_kbn] = 5
      connection[:from_user_id] = @message[:send_user_id]
      connection[:to_user_id] = @message[:receive_user_id]
      connection[:target_id] =  @message[:id]
      set_create_user_id(connection)
      if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
        connection[:new_flg] = 1
      end
      if !connection.save
        render :json => connection.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      connection = Connection.new()
      connection[:connect_kbn] = 6
      connection[:from_user_id] = @message[:receive_user_id]
      connection[:to_user_id] = @message[:send_user_id]
      connection[:target_id] =  @message[:id]
      set_create_user_id(connection)
      if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
        connection[:new_flg] = 1
      end
      if !connection.save
        render :json => connection.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      
      # メッセージ送信処理
      fromUser = User.find(@message[:send_user_id])
      toUser = User.find(@message[:receive_user_id])

      linkUrl = request.url.gsub("api/messages/propose", "") + "mypage/3"
      content = @message[:content]
      if @message[:content].length > 3
        content = @message[:content][0, (@message[:content].length - 3)] + "..."
      end
      
      item = Item.find(@message[:item_id])
      
      @mail = PostMailer.notice_message_ok(fromUser[:email], toUser[:email], fromUser[:display_name], toUser[:display_name], item[:title], content, linkUrl)
      @mail.deliver_now # if Rails.env.production? 
      
      render :json => itemPropose
    end

    return;      
    
  rescue => ex
    logger.fatal controller_name + " " + action_name + " " + ex.message
    errors = Hash.new
    errors[:error_message] = Array.new(1, "予期せぬエラーが発生しました。")
    render :json => errors, status: :unprocessable_entity
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:item_id, :parent_id, :send_user_id, :receive_user_id, :title, :content, :create_user_id, :update_user_id)
    end
end
