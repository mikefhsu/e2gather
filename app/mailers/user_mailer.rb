class UserMailer < ActionMailer::Base
  default from: "e2gather@gmail.com"
  
  def welcome_email(user, add, content)
    @user = user
    mail(:to =>  add, :subject => content)
	#redirect_to action: :loginFacebook
  end

end
