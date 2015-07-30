class PostMailer < ApplicationMailer
  default from: "info@apps-work.com"

  def complete_registration(user, request)
    @user = user
    @email_token = encodeURIComponent(user[:email_token])
    
    @emailurl = ""
    if request.port.to_s == "3000"
      @emailurl = "https://" + request.host + ":" + request.port.to_s + "?email_token="
    else
      @emailurl = "https://" + request.host + "?email_token="
    end
    mail from: "info@apps-work.com", to: user[:email], subject: "[AppsWork] メールアドレス認証のお願い"
  end  
  
  def encodeURIComponent(str)
    unescaped_form = /([#{Regexp.escape(';/?:@&=+$,<>#%"{}|\\^[]`' + (0x0..0x1f).map{|c| c.chr }.join + "\x7f" + (0x80..0xff).map{|c| c.chr }.join)}])/n
    str.force_encoding("ASCII-8BIT").gsub(unescaped_form){ "%%%02X" % $1.ord } 
  end
  
  def notice_proposes(fromMailAddr, toMailAddr, fromUserName, toUserName, workTitle, content, linkUrl)
    @fromMailAddr = fromMailAddr
    @fromUserName = fromUserName
    @toUserName = toUserName
    @workTitle = workTitle
    @linkUrl = linkUrl + "mypage/4"
    @content = content
    
    mail to: toMailAddr, subject: "[AppsWork] お知らせ提案受付メールの"
  end  

  def notice_message(fromMailAddr, toMailAddr, fromUserName, toUserName, content, linkUrl)
    @fromMailAddr = fromMailAddr
    @fromUserName = fromUserName
    @toUserName = toUserName
    @linkUrl = linkUrl
    @content = content
    
    mail to: toMailAddr, subject: "[AppsWork] " + fromUserName + "さんからメッセージを受信しました"
  end  

  def notice_message_ok(fromMailAddr, toMailAddr, fromUserName, toUserName, title, content, linkUrl)
    @fromMailAddr = fromMailAddr
    @fromUserName = fromUserName
    @toUserName = toUserName
    @linkUrl = linkUrl
    @workTitle = title
    @content = content
    
    mail to: toMailAddr, subject: "[AppsWork] 提案されたお仕事の同意のお知らせ"
  end  
    
end
