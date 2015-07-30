class UsersController < ApplicationController
  before_action :check_logined, only: [:list, :update_user, :upload]

  # GET /users
  # GET /users.json
  def index
  end

  # GET /users/1
  # GET /users/1.json
  def show
    cond = Hash.new
    logger.debug params[:id]
    cond[:user_id] = params[:id]

    sql = ""
    sql += "select ur.id user_id "
    sql += ",ur.display_name user_name "
    sql += ",case when ur.sex = 203 then '' else nm_sex.name end sex_name "
    sql += ",ur.birthday "
    sql += ",'' birthday_str "
    sql += ",nm_area.name area_name "
    sql += ",nm_user_kbn.name user_kbn_name "
    sql += ",case when ifnull(ur.content, '') = '' then '登録がありません' else ur.content end content "
    sql += ",case when ifnull(ur.img_path, '') = '' then '/assets/person.jpg' else ur.img_path end img_path "
    sql += ",null as work_categories "
    sql += "from users ur "
    sql += "left join names nm_sex "
    sql += "on nm_sex.id = ur.sex "
    sql += "left join names nm_area "
    sql += "on nm_area.id = ur.area "
    sql += "left join names nm_user_kbn "
    sql += "on nm_user_kbn.id = ur.user_kbn "
    sql += "where ur.id = :user_id "
    
    # 検索してデータをjsonで返す
    users = User.find_by_sql([sql, cond])
        
    if users.nil? || users.size == 0
      render :json => ""
    else
      sql = ""
      sql += "select nm.id as name_id "
      sql += ",nm.name as wk_name "
      sql += "from users ur "
      sql += "inner join user_work_categories wc "
      sql += "on wc.user_id = ur.id "
      sql += "left join names nm "
      sql += "on nm.id = wc.name_id "
      sql += "where ur.id = :user_id "
      
      # 検索してデータをjsonで返す
      works = User.find_by_sql([sql, cond])
      users[0]['work_categories'] = works

      if !users[0][:birthday].nil? && !users[0][:birthday].blank?
        users[0][:birthday_str] = users[0][:birthday].strftime("%Y-%m-%d")
      else
        users[0][:birthday_str] = ""
      end
      
      if !session[:user_id].nil? && session[:user_id] != users[0][:user_id]
        # つながり追加処理
        connection = Connection.new()
        connection[:connect_kbn] = 7
        connection[:from_user_id] = session[:user_id]
        connection[:to_user_id] = users[0][:user_id]
        connection[:target_id] = users[0][:user_id]
        set_create_user_id(connection)
        if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
          connection[:new_flg] = 1
        end
        if !connection.save
          render :json => connection.errors, status: :unprocessable_entity
          return
        end

        connection = Connection.new()
        connection[:connect_kbn] = 8
        connection[:from_user_id] = users[0][:user_id]
        connection[:to_user_id] = session[:user_id]
        connection[:target_id] = users[0][:user_id]
        set_create_user_id(connection)
        if is_find_connect_to_user(connection[:from_user_id], connection[:to_user_id])
          connection[:new_flg] = 1
        end
        if !connection.save
          render :json => connection.errors, status: :unprocessable_entity
          return
        end

      end
 
      render :json => users[0]
    end
    
  end

  # GET /users/new
  def new
  end

  # GET /users/login
  def login
    errors = Hash.new
    
    if params[:email].blank?
      errors[:email] = Array.new(1, "を入力してください。")
    end
    
    if params[:password].blank?
      errors[:password] = Array.new(1, "を入力してください。")
    end

    if !errors[:email].nil? || !errors[:password].nil?
      render :json => errors, status: :unprocessable_entity
      return
    end
    
    @user = User.find_by(["email = ? and password = ?", params[:email], params[:password]])
    if @user.nil?
      errors[:error_message] = Array.new(1, "メールアドレス、または、パスワードが不正です。")
      render :json => errors, status: :unprocessable_entity
    else
      
      reset_session_ex
      session[:display_name] = @user[:display_name]
      session[:user_id] = @user[:id]
      session[:save_login_flg] = params[:save_login_flg]
      
      @user[:password] = form_authenticity_token;
      
      render :json => @user
    end
  end

  # GET /users/mail_auth
  def mail_auth
    errors = Hash.new
    
    if params[:email_token].blank?
      render :json => "", status: :unprocessable_entity
      return
    end
    
    @user = User.find_by(["email_token = ?", params[:email_token]])
    if @user.nil? 
      render :json => "", status: :unprocessable_entity
    else
      if @user[:email_auth_flg].nil? || @user[:email_auth_flg] == 0
        @user[:email_auth_flg] = 1
        @user.save
        render :json => ""
      else
        errors[:error_message] = Array.new(1, "すでにメール認証済です。")
        render :json => errors, status: :unprocessable_entity
      end      
    end
  end
  
  # GET /users/mypage
  def mypage
    errors = Hash.new

    if session["user_id"].nil? || session["user_id"].blank?
      render :json => ""
      return
    end
    
    ret = check_logined
    if !ret 
      return
    end
    
    cond = Hash.new
    cond[:user_id] = session[:user_id]

    sql = ""
    sql += "select ur.* "
    sql += ",ifnull(nt_msg.nt_count, 0) notification_msg_count"
    sql += ",ifnull(nt_inf.nt_count, 0) notification_inf_count"
    sql += ",'' as work_categories "
    sql += ",'' as current_password "
    sql += "from users ur "
    sql += "left join (select count(nt.id) nt_count, "
    sql += "                  nt.user_id  "
    sql += "           from notifications nt "
    sql += "           where nt.user_id = :user_id "
    sql += "           and nt.notification_kbn = 1 "
    sql += "           group by nt.user_id) nt_msg "
    sql += "on nt_msg.user_id = ur.id "
    sql += "left join (select count(nt.id) nt_count, "
    sql += "                  nt.user_id  "
    sql += "           from notifications nt "
    sql += "           where nt.user_id = :user_id "
    sql += "           and nt.notification_kbn = 2 "
    sql += "           group by nt.user_id) nt_inf "
    sql += "on nt_inf.user_id = ur.id "
    sql += "where ur.id = :user_id "
    
    # 検索してデータをjsonで返す
    users = User.find_by_sql([sql, cond])
    
    if users.nil? || users.size == 0 
      errors[:error_message] = Array.new(1, "データが存在しませんです。")
      render :json => errors, status: :unprocessable_entity
      return
    end
  
    if users[0][:img_path].blank?
      users[0][:img_path] = "/assets/person.jpg"
    end
    
    # 自身の仕事カテゴリの取得
    # sqlセット
    sql = ""
    sql += "select uc.* "
    sql += "from user_work_categories uc "
    sql += "where uc.user_id = :user_id "
    sql += "order by uc.id asc "
    
    # 検索してデータをjsonで返す
    userWorkCategories = UserWorkCategory.find_by_sql([sql, cond])
    if !userWorkCategories.nil? && userWorkCategories.size > 0
      users[0][:work_categories] = userWorkCategories
    end
    users[0][:current_password] = ""
    users[0][:password] = ""
    
    result = Hash.new
    result[:user] = users[0]
    
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
    sql += "      ,ifnull(msg.msg_id, 0) as msg_id "
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
    sql += "on ur.id = it.create_user_id "
    sql += "left join (select max(id) msg_id, item_id, send_user_id from messages where parent_id = 0 group by item_id, send_user_id) msg "
    sql += "on msg.item_id = itp.item_id "
    sql += "and msg.send_user_id = itp.create_user_id "
    sql += "where itp.create_user_id = :user_id "
    sql += "order by itp.created_at desc "
    
    # 検索してデータをjsonで返す
    itemProposes = ItemPropose.find_by_sql([sql, cond])
    if !itemProposes.nil? && itemProposes.size > 0
      result[:work_proposes] = itemProposes
    end

    # 依頼一覧の取得
    # sqlセット
    sql = ""
    sql += "select it.* "
    sql += "      ,ifnull(nm_work.name, '') as work_kbn_name "
    sql += "      ,ifnull(nm_payment.name, '') as payment_kbn_name "
    sql += "      ,ifnull(nm_price.name, '') as price_kbn_name "
    sql += "      ,ifnull(nm_hour_price.name, '') as hour_price_kbn_name "
    sql += "      ,ifnull(nm_week_hour.name, '') as week_hour_kbn_name "
    sql += "      ,ifnull(nm_week_hour_period.name, '') as week_hour_period_kbn_name "
    sql += "      ,null as proposes "
    sql += "from items it "
    sql += "left join names nm_work "
    sql += "on nm_work.id = it.work_kbn "
    sql += "left join names nm_payment "
    sql += "on nm_payment.name_kbn = 10 "
    sql += "and nm_payment.id = it.payment_kbn "
    sql += "left join names nm_price "
    sql += "on nm_price.id = it.price_kbn "
    sql += "left join names nm_hour_price "
    sql += "on nm_hour_price.name_kbn = 11 "
    sql += "and nm_hour_price.id = it.hour_price_kbn "
    sql += "left join names nm_week_hour "
    sql += "on nm_week_hour.name_kbn = 12 "
    sql += "and nm_week_hour.id = it.week_hour_kbn "
    sql += "left join names nm_week_hour_period "
    sql += "on nm_week_hour_period.name_kbn = 13 "
    sql += "and nm_week_hour_period.id = it.week_hour_period_kbn "
    sql += "where it.create_user_id = :user_id "
    sql += "order by it.created_at desc "
    
    # 検索してデータをjsonで返す
    items = Item.find_by_sql([sql, cond])
    
    cond[:item_id] = session[:user_id]
    if !items.nil? && items.size > 0
      for item in items
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
        cond[:item_id] = item[:id]
        itemProposes = ItemPropose.find_by_sql([sql, cond])
        if !itemProposes.nil? && itemProposes.size > 0
          item[:proposes] = itemProposes
        end      
        
      end 
      
      result[:items] = items
    end
    
    render :json => result
    
  end

  # GET /users/list
  def list
    
    errors = Hash.new
    if params[:user_name].blank? 
      errors[:error_message] = Array.new(1, "ユーザー名、または、メールアドレスを入力してください。")
      render :json => errors, status: :unprocessable_entity
      return
    end
    
    cond = Hash.new
    cond[:user_name] = "%" + params[:user_name] + "%"
    cond[:user_id] = session[:user_id]
    
    sql = ""
    sql += "select ur.id user_id "
    sql += "      ,ur.display_name user_name "
    sql += "      ,ur.img_path "
    sql += "from users ur "
    sql += "where (ur.display_name like :user_name or ur.email like :user_name) "
    sql += "and ur.id <> :user_id "
    
    # 検索してデータをjsonで返す
    users = User.find_by_sql([sql, cond])
    
    if users.nil? || users.size == 0 
      errors[:error_message] = Array.new(1, "データが存在しません。")
      render :json => errors, status: :unprocessable_entity
      return
    end
    
    render :json => users
    
  end

  def logout
    reset_session_ex
    result = Hash.new
    result[:password] = form_authenticity_token
    render :json => result
  end

  # POST /users
  # POST /users.json
  def create

    @user = User.new(user_params, "")
#    @user[:email_token] = SecureRandom.base64[0...30]
#    @user[:email_token] = SecureRandom.uuid
    @user[:email_token] = SecureRandom.urlsafe_base64
    
    isSaved = false;

    ActiveRecord::Base.transaction do
      isSaved = @user.save!
      @mail = PostMailer.complete_registration(@user, request)
      @mail.deliver_now # if Rails.env.production?
      @user[:password] = "";
      render :json => @user
    end

  rescue => ex
    if !isSaved
      render :json => @user.errors, status: :unprocessable_entity
    else
      logger.fatal controller_name + " " + action_name + " " + ex.message
      errors = Hash.new
      errors[:error_message] = Array.new(1, "予期せぬエラーが発生しました。")
      render :json => errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update_user

    @user = User.find(params[:id])
    get_params = user_params
    
    if !params[:tmp_img_path].blank? && !params[:tmp_file_name].blank?
      FileUtils.mv(params[:tmp_img_path], "public/img/uploads/profile/" + params[:tmp_file_name])
      get_params[:img_path] = "img/uploads/profile/" + params[:tmp_file_name]
    end
    
    if get_params['password'].blank?
      if !params['current_password'].blank?
         @user.errors.add(:password, "を入力してください")
         render :json => @user.errors, status: :unprocessable_entity
         return
      end
      get_params['password'] = @user['password']      
    else
       if params['current_password'].blank?
         @user.errors.add(:current_password, "を入力してください")
         render :json => @user.errors, status: :unprocessable_entity
         return
       else
         if params['current_password'] != @user['password']
           @user.errors.add(:current_password, "が一致しません")
           render :json => @user.errors, status: :unprocessable_entity
           return
         end
       end
    end
    
    logger.debug get_params['birthday']
    if !get_params['birthday'].blank?
      if get_params['birthday'].length != 10
           @user.errors.add(:birthday, "の形式が不正です(YYYY-MM-DD)")
           render :json => @user.errors, status: :unprocessable_entity
           return
      end

      if (DateTime.parse(get_params['birthday']) rescue ArgumentError) == ArgumentError
           @user.errors.add(:birthday, "の形式が不正です(YYYY-MM-DD)")
           render :json => @user.errors, status: :unprocessable_entity
           return
      end
    end

    
    ActiveRecord::Base.transaction do
      if @user.update(get_params)
        render :json => @user
      else
        render :json => @user.errors, status: :unprocessable_entity
      end
      
    end

  rescue => ex
    logger.debug ex.message
    render :json => @user.errors, status: :unprocessable_entity
  end
  
  # POST /users/upload
  def upload
    file = params[:avatar]
    
    fileName = Time.now.instance_eval { '%s%03d' % [strftime('%Y%m%d%H%M%S'), (usec / 1000.0).round] }
    fileName = fileName + File.extname(file.original_filename)
    
    File.open("public/img/uploads/temp/#{fileName}", 'wb') { |f|
      f.write(file.read)
    }
    
    result = Hash.new
    result[:img_path] = "img/uploads/temp/" + fileName
    result[:img_file_name] = file.original_filename
    result[:tmp_img_path] = "public/img/uploads/temp/" + fileName
    result[:tmp_file_name] = fileName
    
    render :json => result

  rescue => ex
    logger.debug ex.message
    render :json => @user.errors, status: :unprocessable_entity
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      #@user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:unique_id, :email, :password, :display_name, :content, :img_path, :img_file_name, :email_token, :user_kbn, :sex, :birthday, :area, :create_user_id, :update_user_id)
    end
end
