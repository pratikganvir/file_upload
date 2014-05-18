class UserMailer < ActionMailer::Base
  CLIENT_EMAIL = "chaitali.khangar@cipher-tech.com"

  #--
  #
  #++
  def reset_password_mail_by_api(user,temp_password)
  	@user = user
  	@temp_password = temp_password
    mail( :to => user.email,      
      :subject => "String7:- Password Changed",
      :from => CLIENT_EMAIL)
  end
end
