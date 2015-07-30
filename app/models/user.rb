class User < ActiveRecord::Base
   VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
   validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, length: { maximum: 255 }, if: :new_regist?
   validates_uniqueness_of :email, :message => 'はすでに登録されています。'
   VALID_PASS_REGEX = /[0-9].*[a-zA-Z]|[a-zA-Z].*[0-9]/
   validates :password, presence: true, length: { in: 6..15 }
   validates :password, format: { with: VALID_PASS_REGEX, message: 'は半角英数混在で入力してください' }
   VALID_NAME_REGEX = /[a-z\d\-.]/
   validates :display_name, presence: true, length: { in: 4..10 }
   validate :display_name_valid
#   validates :display_name, format: { with: VALID_NAME_REGEX, message: 'は半角英数、(記号「@_-」)で入力してください' }
   
  def new_regist?
    if (id.nil? || id == 0) 
      return true
    else
      return false
    end
  end
  
  def check_user_password
     
  end
  
  def display_name_valid()
    if !(/\A[A-Za-z]+\z/ =~ display_name.gsub(/[0-9@_-]/,""))
      errors.add(:display_name, "は半角英数、記号「@_-」で入力してください(数字、記号のみは不可)")
    end
  end
   
end
