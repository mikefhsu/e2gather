require 'test_helper'
require 'yaml'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  @@event_name = "Test123"
  @@event_host = "TestHost"
  @@event_location = "Test location"
  @@event_status = "Pending"
  @@valid_date = DateTime.new(2014, 11, 24, 8, 52)
  @@invalid_date = DateTime.new(2012, 11, 24, 8, 52)
  @@within_bound = "wOElKAmO0dkOSGsxVif8IYZyRPdzAfJFVhMkuXjKuCza2mniJ7a7VelVIGBstd7QnGj0xQFzOGmBQgnGmQ25yg0HTAqaxZjZAyKP7GKNzkOQFHVqsh7pAnAGUNA3La1LboGDNmuto0SyJCtAYvVAFHqcf5g0bhasQddt4d5iQUc85UTkJCmoUgltrESxSKRZrhxiT3WMMNXdlPQ7RhKdSMI0wd98dUOOu09Jgyt83ZDls6iPLAurgZnbQqljyGm"
  @@out_bound = "wOElKAmO0dkOSGsxVif8IYZyRPdzAfJFVhMkuXjKuCza2mniJ7a7VelVIGBstd7QnGj0xQFzOGmBQgnGmQ25yg0HTAqaxZjZAyKP7GKNzkOQFHVqsh7pAnAGUNA3La1LboGDNmuto0SyJCtAYvVAFHqcf5g0bhasQddt4d5iQUc85UTkJCmoUgltrESxSKRZrhxiT3WMMNXdlPQ7RhKdSMI0wd98dUOOu09Jgyt83ZDls6iPLAurgZnbQqljyGmI"

  test "should save event by complete information successfully" do
	puts "Check within bound: " + @@within_bound.length.to_s
	puts "Check out_bound: " + @@out_bound.length.to_s
	
  	e = Event.new
	e.name = @@event_name
	e.host = @@event_host
	e.location = @@event_location
	e.event_id = Time.now.to_i
	e.status = @@event_status
	
	# Set date and time
    	e.date_time = @@valid_date

    	# Collect ingredient and guest
    	ingredient_list =[]
	
    	ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
    	ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
    	ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

    	# Add ingredient and guest to database
    	e.ingredient_list = ingredient_list.to_s
    	e.guest_list = ""
    	e.accept = 0
    	e.reject = 0
    	e.unconfirmed = ""

	assert e.save
  end

  test "should not save event by empty host" do
	e = Event.new
        e.name = @@event_name
        e.location = @@event_location
        e.event_id = Time.now.to_i
        e.status = @@event_status

        # Set date and time
        e.date_time = @@valid_date

        # Collect ingredient and guest
        ingredient_list =[]

        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

        # Add ingredient and guest to database
        e.ingredient_list = ingredient_list.to_s
        e.guest_list = ""
        e.accept = 0
        e.reject = 0
        e.unconfirmed = ""

        assert !e.save, "Save the event without a host"
  end

  test "should not save event by empty date" do
  	e = Event.new
	e.name = @@event_name
	e.host = @@event_host
	e.location = @@event_location
	e.event_id = Time.now.to_i
	e.status = @@event_status
	
	# Collect ingredient and guest
        ingredient_list =[]

        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

        # Add ingredient and guest to database
        e.ingredient_list = ingredient_list.to_s
        e.guest_list = ""
        e.accept = 0
        e.reject = 0
        e.unconfirmed = ""

        assert !e.save, "Save the event without a date"
  end

  test "should not have events that have date is in the past" do
	e = Event.new
	e.name = @@event_name
	e.host = @@event_host
	e.location = @@event_location
	e.event_id = Time.now.to_i
	e.status = @@event_status
	
	# Set date and time
        e.date_time = @@invalid_date

	# Collect ingredient and guest
        ingredient_list =[]

        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

        # Add ingredient and guest to database
        e.ingredient_list = ingredient_list.to_s
        e.guest_list = ""
        e.accept = 0
        e.reject = 0
        e.unconfirmed = ""

	assert !e.save, "Save the event with the date that has been passed"
  end

  test "should have multiple events that has the same date, ingredients and guests without the same hosts" do
  	#Create multiple events with the same contents except hosts
	test_event_list = []
	for i in 0...3
		e = Event.new
		e.name = @@event_name
		e.host = @@event_host
		e.location = @@event_location
		e.event_id = 123
		e.status = @@event_status
		e.date_time = @@valid_date
		
		# Collect ingredient and guest
        	ingredient_list =[]
        	ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
        	ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
        	ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

        	# Add ingredient and guest to database
        	e.ingredient_list = ingredient_list.to_s
        	e.guest_list = ""
        	e.accept = 0
        	e.reject = 0
        	e.unconfirmed = ""
  		
		test_event_list[i] = e
	end
	
	fake_id = 0
	test_event_list.each {|tmp|
		tmp.host = "TestHost"
		fake_id += 1
	}

	assert test_event_list[0].save && test_event_list[1].save && test_event_list[2].save, "Save the events that has absolutely the same contents with different hosts"
  end

  test "should not have event with the length of name larger than 255" do
  	e = Event.new
	e.name = @@out_bound
	e.host = @@event_host
        e.location = @@event_location
	e.event_id = Time.now.to_i
	e.status = @@event_status
        e.date_time = @@valid_date

	# Collect ingredient and guest
        ingredient_list =[]

        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

        # Add ingredient and guest to database
        e.ingredient_list = ingredient_list.to_s
        e.guest_list = ""
        e.accept = 0
        e.reject = 0
        e.unconfirmed = ""
	
	assert !e.save, "Save the event with name length larger than 255"

  end

  test "should have event with the length of name equal to 255" do
  	e = Event.new
	e.name = @@within_bound
        e.location = @@event_location
	e.event_id = Time.now.to_i
	e.status = @@event_status
	e.date_time = @@valid_date

	# Collect ingredient and guest
        ingredient_list =[]

        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

        # Add ingredient and guest to database
        e.ingredient_list = ingredient_list.to_s
        e.guest_list = ""
        e.accept = 0
        e.reject = 0
        e.unconfirmed = ""

        assert e.save, "Save the event with name length eaual to 255"
  end 

  test "should not have event with the location with length larger than 255" do
  	e = Event.new
	e.name = @@event_name
	e.location = @@out_bound
	e.event_id = Time.now.to_i
	e.status = @@event_status
	e.date_time = @@valid_date
	
	# Collect ingredient and guest
        ingredient_list =[]

        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

        # Add ingredient and guest to database
        e.ingredient_list = ingredient_list.to_s
        e.guest_list = ""
        e.accept = 0
        e.reject = 0
        e.unconfirmed = ""

        assert !e.save, "Save the event with location length larger than 255"
  end

  test "should have event with the location with length equalt to 255" do
        e = Event.new
        e.name = @@event_name
        e.location = @@within_bound
        e.event_id = Time.now.to_i
        e.status = @@event_status
        e.date_time = @@valid_date

        # Collect ingredient and guest
        ingredient_list =[]

        ingredient_list << Ingredient.new( :name=>  "ingred1", :ingredient_id =>0, :quantity=> 1,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred2", :ingredient_id =>0, :quantity=> 2,  :unit=>0, :user_id=> 0)
        ingredient_list << Ingredient.new( :name=>  "ingred3", :ingredient_id =>0, :quantity=> 3,  :unit=>0, :user_id=> 0)

        # Add ingredient and guest to database
        e.ingredient_list = ingredient_list.to_s
        e.guest_list = ""
        e.accept = 0
        e.reject = 0
        e.unconfirmed = ""

        assert e.save, "Save the event with location length eaual to 255"
  end
end
