class UserMailer < ActionMailer::Base
  default from: "e2gather@gmail.com"
  
  def welcome_email(user, add,id, content)
    @user = user
    mail(:to =>  add, :subject => 'Your friend '+id +' has just sent you a email', :body=> content)
	#redirect_to action: :loginFacebook
  end

end
