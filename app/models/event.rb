class Event < ActiveRecord::Base
  self.primary_key='id'
  belongs_to :user, foreign_key: "host"
  has_many :ingredients
  validates_presence_of :name

  @@accept_msg = " has accepted your invitation for "
  @@reject_msg = " has rejected your invitation for "
  @@complete_msg = "All guests have responded to your "

  def notify_host(host, guest_name, flag)
    if flag == 1
      mail_body = guest_name + @@accept_msg + self.name + " event"
    elsif flag == 0
      mail_body = guest_name + @@reject_msg + self.name + " event"
    else
      mail_body = @@complete_msg + self.name + " event"
      UserMailer.complete_email(host, self.name, mail_body).deliver
      return
    end
    UserMailer.update_email(host, guest_name, self.name, mail_body).deliver
  end

  def notify_guests(guest_list, raw_ingreds, flag)
    final_flag = -1;
    if flag == 1
      mail_body = self.name + 
        " event has been confirmed!! \n" +
        "Location: " + self.location + "\n" +
        "Guests: " + self.guest_list + "\n" +
        "Ingredients: " + raw_ingreds + "\n"
        "Look forward to meeting you!!!\n" +
        "Your friend --" + self.host
        final_flag = 1
    else
      mail_body = self.name + " event has been cancelled... \n" +
        "See you next time !!\n" +
        "Your friend --" + self.host
        final_flag = 0
    end
    
    guest_list.each {|tmp|
      UserMailer.result_email(tmp, self.name, mail_body, final_flag).deliver
    }
  end
end
