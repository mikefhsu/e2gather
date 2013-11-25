require 'test_helper'
require 'yaml'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:one)
	
	# Create three users for testing
	user1 = User.new(:user_id => "100005852740904", :name => "Peter Louis Terry",:email => "mike.fh.su@gmail.com")
        user1.save

	user2 = User.new(:user_id => "1226970106", :name => "Lindsay Neubauer", :email => "neubauer.lindsay@gmail.com ")
	user2.save

	user3 = User.new(:user_id => "100001069360694", :name => "Chang Le", :email => "changle@live.cn")
	user3.save

	@current_user = user1
	session[:user_id] = @current_user.user_id
	
	#Create fake event
	@event = Event.new
	@event.name = "For test"
	@event.location = "TestLocation"
	@event.event_id = Time.now.to_i
	@event.host = @current_user.name
	@event.guest_list = "Lindsay Neubauer,Chang Le"

	#Create fake ingredient
	ingredient_list =[]
        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> "1226970106")
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> "100001069360694")
	@event.ingredient_list = YAML.dump(ingredient_list)
	@event.unconfirmed = ""
	@event.accept = 2
        @event.reject = 0

	@event.save
  end

  def teardown
	@event = nil
	@current_user = nil
  end

  test "should finalize hold event" do
  	post(:finalized, {"e_id" => @event.id, "option" => "1"})
	assert_template "event_finalized"
	assert_response :success
  end

  test "should not finalize hold event" do
  	@event.unconfirmed = "test123"
	@event.save
        post(:finalized, {"e_id" => @event.id, "option" => "1"})
	assert_response :redirect
	assert_redirected_to(controller: "e2gather")
  end

  test "should finalize cancelled event" do
  	post(:finalized, {"e_id" => @event.id, "option" => "2"})
	assert_template "events/event_finalized"
	assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, event: { date_time: @event.date_time, event_id: @event.event_id, guest_list: @event.guest_list, host: @event.host, ingredient_list: @event.ingredient_list, location: @event.location, name: @event.name, status: @event.status }
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    get :show, id: @event
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event
    assert_response :success
  end

  test "should update event" do
    patch :update, id: @event, event: { date_time: @event.date_time, event_id: @event.event_id, guest_list: @event.guest_list, host: @event.host, ingredient_list: @event.ingredient_list, location: @event.location, name: @event.name, status: @event.status }
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, id: @event
    end

    assert_redirected_to events_path
  end
end
