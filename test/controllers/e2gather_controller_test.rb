require 'test_helper'

class E2gatherControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  setup do
    @event = events(:one)

        # Create four users for testing
        @user1 = User.new(:user_id => "100005852740904", :name => "Peter Louis Terry",:email => "mike.fh.su@gmail.com")
        @user1.save

        @user2 = User.new(:user_id => "1226970106", :name => "Lindsay Neubauer", :email => "neubauer.lindsay@gmail.com ")
        @user2.save

        @user3 = User.new(:user_id => "100001069360694", :name => "Chang Le", :email => "changle@live.cn")
        @user3.save

	@user4 = User.new(:user_id => "100001504510790", :name => "Wei Duan", :email => "sylvia_duan@hotmail.com")
	@user4.save

	@ingred1 = Ingredient.new(:name=> "ingred1", :ingredient_id=> 1, :quantity=> 1, :unit=> "dozen", :user_id=> "1226970106")
	@ingred1.save

	@ingred2 = Ingredient.new(:name=> "ingred2", :ingredient_id=> 2, :quantity=> 2, :unit=> "dozen", :user_id=> "100001069360694")
	@ingred2.save
	
	@ingred3 = Ingredient.new(:name=> "ingred2", :ingredient_id=> 3, :quantity=> 1, :unit=> "dozen", :user_id=> "100001504510790")
	@ingred3.save

        @current_user = @user1
        session[:user_id] = @current_user.user_id

        #Create fake event
        @event = Event.new
        @event.name = "For test"
        @event.location = "TestLocation"
        @event.event_id = Time.now.to_i
        @event.host = @current_user.name
	@event.status = "Pending"

        #Create fake ingredient
        ingredient_list =[]
        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>"dozen", :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>"dozen", :user_id=> 0)
        @event.ingredient_list = YAML.dump(ingredient_list)
        @event.unconfirmed = ""
        @event.accept = 0
        @event.reject = 0

        @event.save
  end

  def teardown
  	@event = nil
	@current_user = nil
  end

  test "should find out guest for event" do
  	get(:pick_guest_page, {"e_id" => @event.id})
	assert_response :success
  end

  test "should send message" do
  	post(:sendmsg, {"my_email" => @current_user.email, "id" => @current_user.user_id})
	assert_response :redirect
	assert_redirected_to(controller: "e2gather", action: "loginFacebook")
  end

  test "should render event page" do
  	get(:render_event_page)
	assert_template("new_user_event")
  end

  test "should rebder ingredient page" do
  	get(:render_ingredient_page)
	assert_template("new_ingredient")
  end
end
