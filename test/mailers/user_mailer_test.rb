require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  @@guest = 'Le'
  @@g_email ='changle@live.cn'
  @@host= 'Mike'
  @@ingredient = 'rice'
  @@q = '1'
  @@E_name= 'Dinner_Party'
  @@user =User.new(:user_id=> '10000213421312' , :email=> 'changle@live.cn', :name=> 'Le Chang')
  
  
   test "No emails to be sent at the beginning" do
      #  e = Event.new
		#ActionMailer::Base.deliveries.last.to.should == ['changle@live.cn']
		assert_equal nil, ActionMailer::Base.deliveries.last
       # assert e.save, "Save the event with location length eaual to 255"
  end
  
  test "invite email should not contain 0 guest" do
    # Send the email, then test that it got queued or not
    s=ActionMailer::Base.deliveries.size
	assert_raises(ArgumentError) {
		email = UserMailer.invite_email('Le', '', '', '1' ,'rice', '1').deliver
		UserMailer.result_email(nil,@@E_name, '', 0).deliver
		UserMailer.update_email('',nil, @@E_name, '').deliver
		UserMailer.complete_email(nil,@@E_name, '').deliver
	}
    assert_equal ActionMailer::Base.deliveries.size, s
 
    # Test the body of the sent email contains what we expect it to
   # assert_equal ['me@example.com'], email.from
  #  assert_equal ['friend@example.com'], email.to
  #  assert_equal 'You have been invited by me@example.com', email.subject
   # assert_equal read_fixture('invite').join, email.body.to_s
  end
  
  test "invite email could be sent to 1 guest" do
    # Send the email, then test that it got queued or not
	
		email = UserMailer.invite_email(@@host, @@g_email, @@guest, @@q ,@@ingredient,@@E_name).deliver
    assert !ActionMailer::Base.deliveries.empty?
 
    # Test the body of the sent email contains what we expect it to
     assert_equal ['e2gather@gmail.com'], email.from
    assert_equal [@@g_email], email.to
    assert_equal 'Your friend '+@@host +' has just invited you to '+@@E_name, email.subject
    assert_equal "
	 Hi, "+@@guest +",please bring " + @@q +" unit(s) of "+@@ingredient+" to "+@@E_name+", if you are interested in! Please log into 
	 e2gather to confirm or reject this event!\n
	 The E2Gather Team ", email.body.to_s
  end

    test "invite email could be sent to 100 guest" do
    # Send the email, then test that it got queued or not
	100.times{ |i|
		s =ActionMailer::Base.deliveries.size
		email = UserMailer.invite_email(@@host, @@g_email, @@guest, @@q ,@@ingredient,@@E_name).deliver
    assert_equal ActionMailer::Base.deliveries.size, s+1
 
    # Test the body of the sent email contains what we expect it to
     assert_equal ['e2gather@gmail.com'], email.from
    assert_equal [@@g_email], email.to
    assert_equal 'Your friend '+@@host +' has just invited you to '+@@E_name, email.subject
    assert_equal "
	 Hi, "+@@guest +",please bring " + @@q +" unit(s) of "+@@ingredient+" to "+@@E_name+", if you are interested in! Please log into 
	 e2gather to confirm or reject this event!\n
	 The E2Gather Team ", email.body.to_s
	}
  end
  

  
  
    test "result email to guest when the event is going be held ,flag ==1" do
    # Send the email, then test that it got queued or not

	UserMailer.result_email(@@user,@@E_name, '', 1).deliver
	result_email = ActionMailer::Base.deliveries.last
    #assert !ActionMailer::Base.deliveries.empty?
 
    # Test the body of the sent email contains what we expect it to
     assert_equal ['e2gather@gmail.com'], result_email.from
    assert_equal [@@user.email], result_email.to
    assert_equal @@E_name + " will be hold!!!", result_email.subject
    assert_equal '', result_email.body.to_s
  end
  
    test "result email to guest when the event is cancelled ,flag ==0" do
    # Send the email, then test that it got queued or not

	UserMailer.result_email(@@user,@@E_name, '', 0).deliver
	result_email = ActionMailer::Base.deliveries.last
    #assert !ActionMailer::Base.deliveries.empty?
 
    # Test the body of the sent email contains what we expect it to
     assert_equal ['e2gather@gmail.com'], result_email.from
    assert_equal [@@user.email], result_email.to
    assert_equal @@E_name + " is cancelled...", result_email.subject
    assert_equal '', result_email.body.to_s
  end
  
  ##Probably a bug  
  test "No result email to guest when flag is invalid" do
    # Send the email, then test that it got queued or not
	s = ActionMailer::Base.deliveries.size
	UserMailer.result_email(@@user,@@E_name, '', -1).deliver
	assert_equal ActionMailer::Base.deliveries.size,s
	#result_email = ActionMailer::Base.deliveries.last
    #assert !ActionMailer::Base.deliveries.empty?
 
   # Test the body of the sent email contains what we expect it to
   #assert_equal ['e2gather@gmail.com'], result_email.from
   # assert_equal [@@user.email], result_email.to
   # assert_equal @@E_name + " is cancelled...", result_email.subject
   # assert_equal '', result_email.body.to_s
  end
  
  def update_email(receiver, guest_name, event_name, content)
    mail(:to => receiver.email, :subject => "Your guest " + guest_name + " has updated your event " + event_name, :body => content)
  end
  
  def complete_email(receiver, event_name, content)
    mail(:to => receiver.email, :subject => "Your " + event_name + " has been complete", :body => content)
  end
  
   test "Update email to 1 guest" do
    # Send the email, then test that it got queued or not

	UserMailer.update_email(@@user,@@guest, @@E_name, '').deliver
	result_email = ActionMailer::Base.deliveries.last
    #assert !ActionMailer::Base.deliveries.empty?
 
    # Test the body of the sent email contains what we expect it to
     assert_equal ['e2gather@gmail.com'], result_email.from
    assert_equal [@@user.email], result_email.to
    assert_equal "Your guest " + @@guest + " has updated your event " + @@E_name, result_email.subject
    assert_equal '', result_email.body.to_s
  end
  
    test "Complete email to 1 host" do
    # Send the email, then test that it got queued or not

	UserMailer.complete_email(@@user,@@E_name, '').deliver
	result_email = ActionMailer::Base.deliveries.last
    #assert !ActionMailer::Base.deliveries.empty?
 
    # Test the body of the sent email contains what we expect it to
     assert_equal ['e2gather@gmail.com'], result_email.from
    assert_equal [@@user.email], result_email.to
    assert_equal  "Your " + @@E_name + " has been complete" , result_email.subject
    assert_equal '', result_email.body.to_s
  end
  
end
