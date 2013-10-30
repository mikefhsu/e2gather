class UserMailer < ActionMailer::Base
  default from: "e2gather@gmail.com"
  
  def welcome_email(user, add,id, content)
    @user = user
    mail(:to =>  add, :subject => 'Your friend '+id +' has just sent you a email', :body => content)
	#redirect_to action: :loginFacebook
  end
  
  def update_email(receiver, guest_name, event_name, content)
    mail(:to => receiver.email, :subject => "Your guest " + guest_name + " has updated your event " + event_name, :body => content)
  end
  
  def complete_email(receiver, event_name, content)
    mail(:to => receiver.email, :subject => "Your " + event_name + " has been complete", :body => content)
  end
  
  def result_email(receiver, event_name, content, flag)
    if flag == 1
      mail(:to => receiver.email, :subject => event_name + " will be hold!!!", :body => content)
    else
      mail(:to => receiver.email, :subject => event_name + " is cancelled...", :body => content)
    end
  end

end
