namespace :autologout do
  task :clear_session => :environment do
    results = ActiveRecord::Base.connection.select_all( "SELECT * FROM sessions" )
    if results.nil? || results.length == 0 
      return
    end
    
    # 5分操作させていなければ自動ログアウトする
    basetime = 5.minutes.ago

    for result in results
      data = Marshal.restore( Base64.decode64( result['data'] ) )
      if !data['save_login_flg'].nil? && data['save_login_flg'] == "1"
        next
      end 

      if result['updated_at'] < basetime
        ActiveRecord::SessionStore::Session.delete(result['session_id'])
        next
      end
      
    end    
  end
end
