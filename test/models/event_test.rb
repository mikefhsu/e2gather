require 'test_helper'
require 'yaml'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should save event by complete information successfully" do
  	e = Event.new
	e.name = "Test123"
	e.host = "TestHost"
	e.location = "Test location"
	e.event_id = Time.now.to_i
	e.status = "Pending"
	
	# Set date and time
    	e.date_time = DateTime.new(2013, 11, 24, 8, 52)

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
        e.name = "Test123"
        e.location = "Test location"
        e.event_id = Time.now.to_i
        e.status = "Pending"

        # Set date and time
        e.date_time = DateTime.new(2013, 11, 24, 8, 52)

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
	e.name = "Test location"
	e.event_id = Time.now.to_i
	e.status = "Pending"
	
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

  test "should not save two events by the same id" do
	e = Event.new
	e.name = "Test1"
	e.event_id = 123
	
	e2 = Event.new
	e.name = "Test2"
	e.event_id = 123

	assert !(e.save && e2.save), "Save the event with the same ids"
  end
end
