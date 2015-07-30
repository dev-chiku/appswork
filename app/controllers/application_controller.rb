class ApplicationController < ActionController::Base
  
  # ログイン認証用のフィルタ
  # before_filter :check_logined

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  protected

  # ログイン認証用のフィルタ
  def check_logined
    logger.debug "check_logined exec"
    if !session[:user_id] || session[:user_id].nil?
      errors = Hash.new
      errors[:error_message] = Array.new(1, "ログインされていません。")
      errors[:is_login_check_error] = true
      render :json => errors, status: :unprocessable_entity
      return false
    end
    
    session_data = read_session(request.session_options[:id]);
    if session_data.nil?
      return false
    end
    
    return true
  end

  # 作成用ユーザーIDのセット
  def set_create_user_id(model)
    model[:create_user_id] = session[:user_id] 
    model[:update_user_id] = session[:user_id] 
  end

  # 更新用ユーザーIDのセット
  def set_update_user_id(model)
    model[:update_user_id] = session[:user_id] 
  end
  
  # セッション読み込み
  def read_session( sess_id )
    result = ActiveRecord::Base.connection.select_all( "SELECT * FROM sessions WHERE session_id = '#{sess_id}'" )
    Marshal.restore( Base64.decode64( result[ 0 ][ 'data' ] ) ) if result[ 0 ]
  end

  # reset_sessionの拡張処理
  def reset_session_ex()
    session[:display_name] = nil
    session[:user_id] = nil
    session[:save_login_flg] = nil
    reset_session
    
    if request.session_options[:id].blank?
      return
    end
    
    sess_id = request.session_options[:id]
    result = ActiveRecord::Base.connection.select_all( "SELECT * FROM sessions WHERE session_id = '#{sess_id}'" )
    
    if result.nil? && result.length > 0
      result[0].destroy
    end
    
  end
  
  def is_find_connect_to_user(from_user_id, to_user_id)
    connection = Connection.find_by(from_user_id: from_user_id, to_user_id: to_user_id)
    return connection.nil?
  end

end
