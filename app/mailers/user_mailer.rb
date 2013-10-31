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
  
  def invite_email(user, email, name, quantity, ingre_name ,event_name)
     mail(:to =>  email, :subject => 'Your friend '+user +' has just invited you to '+event_name, :body => "
	 Hi, "+name +",please bring " +quantity +" unit(s) of "+ingre_name+" to "+event_name+", if you are interested in! Please log into 
	 e2gather to confirm or reject this event!\n
	 The E2Gather Team ")
  end

end
