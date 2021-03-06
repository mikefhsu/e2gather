require 'yaml'
class E2gatherController < ApplicationController
  def index
    puts "Check session " + session.to_s
    session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + '/e2gather/loginFacebook')
    @auth_url =  session[:oauth].url_for_oauth_code(:permissions=>"email,publish_stream,publish_actions") 	
    puts session.to_s + "<<< session"
    respond_to do |format|
      format.html {  }
    end
  end
  
  def logout
    session[:oauth] = nil
    session[:access_token] = nil
    session[:user_id] = nil
    session[:friend_list]=nil
    render :text => "You've logged out!"
  end
  
  def loginFacebook 
    # Get current user
    if params[:code] and session[:access_token].nil?
      # acknowledge code and get access token from FB
      session[:access_token] = session[:oauth].get_access_token(params[:code])
    end		
		  
    # auth established, now do a graph call:  
    @api = Koala::Facebook::API.new(session[:access_token])
    begin
      @graph_data = @api.get_object("/me/statuses", "fields"=>"message")
      user = @api.get_object("me")
  
      puts "Get me " + user.to_s()
      #if session[:user_id].nil?	
      if User.where(user_id: user["id"]).exists?
        @current_user = User.find(user["id"])
      else
        email = ""
        if user["email"].nil?
          email = user["username"] + "@facebook.com"
	      else
          email =  user["email"]
        end
	      #@current_user = Users.new
	      @current_user=User.new(:user_id => user["id"], :name => user["name"],:email => email)
	      @current_user.save
      end 
      
      session[:user_id] = @current_user.user_id       
      puts "Check instance var current_user " + session[:user_id]	 
      puts session[:friend_list].to_s()
      if session[:friend_list] == 0 or session[:friend_list] == nil
        @friends = @api.get_connections(user["id"], "friends")
        @friend_list = getFriendList 
        session[:friend_list] = @friend_list
        puts "Facebook friends: " + @friends.to_s()     
      end
      
      @ingredient_list = Ingredient.where(user_id: user["id"])  
 
    rescue Exception=>ex
      puts ex.message
    end
    
    get_event_list

    respond_to do |format|
      format.html {   }
    end
  end

  def get_event_list
    if session[:user_id].nil?
      loginFacebook
      return
    end
    
    all_list = Event.find_by_sql("SELECT * FROM events ORDER By events.date_time")
    @event_list = all_list.select{|tmp| tmp.host == @current_user.id || tmp.guest_list.split(",").include?(@current_user.id)}
    if @event_list.nil?
      @event_list = Array.new
    end
  end
  
  def sendmsg
    my_email = params['my_email']
    id =  params['id']
    email = User.find(id)['email']
	  name = User.find(id)['name']
	  UserMailer.welcome_email(session[:user_id] ,email,name, my_email).deliver
    redirect_to action: :loginFacebook
  end
  
  def invite_guest
   @current_event = Event.find(params[:e_id])
   @event_ingredient =YAML::load( @current_event.ingredient_list)
   guest_list = ""
   # email_list =[]
   @event_ingredient.each {|tmp|
     if params[tmp.name].nil?
       render "e2gather/error_page"
       return
     end
     guest_list = guest_list + User.find(params[tmp.name]).name + ","
     tmp.user_id = params[tmp.name]
     puts "tmp.id:" + tmp.name
     #tmp.quantity = params[tmp.quantity]
     puts "tmp.quantity:" + tmp.quantity.to_s()
   }
   guest_list = guest_list[0...-1]
   @current_event.guest_list = guest_list
 
   @current_event.ingredient_list = @event_ingredient

   @current_event.unconfirmed = guest_list

   if @current_event.save
     @event_ingredient.each {|tmp| 
       UserMailer.invite_email(User.find(session[:user_id]).name ,User.find(tmp.user_id).email,User.find(tmp.user_id).name, 
       tmp.quantity.to_s(), tmp.name,@current_event.name).deliver
     }
     redirect_to "/e2gather/loginFacebook"
   else
     render "e2gather/error_page"
   end
  end

  def render_event_page
    #Default 1 ingredients
    @emp_ingred = Array.new
    @emp_q = Array.new
	@ing = Array.new
	@qua = Array.new
    for i in 0..0
	@emp_ingred << "ingredient" + i.to_s
	@emp_q << "q" + i.to_s
	@ing<<""
	@qua<<""
    end
	cur_time = Time.now
        @event_time = Time.new(cur_time.year, cur_time.month, cur_time.day + 1, 17, 0, 0);  
    puts "Check emp_ingred " + @emp_ingred.to_s
    render "e2gather/new_user_event"
  end
 
  def pick_guest_page
    @current_event = Event.find(params[:e_id])
    @event_ingredient =YAML::load( @current_event.ingredient_list)
	
    @total_ingred_list = Hash.new
    @event_ingredient.each {|tmp|
      user_ingred = Ingredient.select("user_id").where("name = ? AND quantity >= ?", tmp.name, tmp.quantity)
      puts 'pick_guests: ' + tmp.name
      puts 'pick_guests_ingred: ' + user_ingred.name
      guest_list = [] 
      if !user_ingred.any?()
        guest_list<<[ User.find(session[:user_id]).name , session[:user_id]]
        @total_ingred_list[tmp.name] = guest_list		
      else
        user_ingred.each{|i|
        if session[:friend_list].nil? 
          puts "session[:friend_list] is nil"
          redirect_to "/e2gather/loginFacebook"
          return
        else
          session[:friend_list].each{|f|
            if f["id"] == i["user_id"]
              puts "f=" + f["id"] + "   i=" + i["user_id"] + " -> MATCH"
              guest_list << [ User.find(f["id"]).name , f["id"]]
            else 
              puts "f=" + f["id"] + "   i=" + i["user_id"] + " -> NO MATCH"
            end
          }
          
          if guest_list.length == 0
            guest_list<<[ User.find(session[:user_id]).name , session[:user_id]]
          end
        end
        @total_ingred_list[tmp.name] = guest_list
      }
      end	  
    }
    #redirect_to "/e2gather/loginFacebook"
  end
  
  def is_number(n)
    begin Float(n) ; true end rescue false
  end

  def create_user_event
    if session[:user_id].nil?
      puts "No current user"
      loginFacebook
    end

    if params[:add]
    	#Insert a new entry for ingredient
	
	
	@emp_ingred = session[:emp_ingred]
	@emp_q = session[:emp_q]	
	@ing = session[:ing]
	@qua = session[:qua]	
	
	for i in 0..@emp_ingred.length-1
	  @ing[i] = params[@emp_ingred[i]]
          @qua[i] =  params[@emp_q[i]]
	end
	
	@event_name = params[:name]
	@event_location = params[:location]
	date_hash1 = params[:date_time]
	@event_time = Time.new(date_hash1["(1i)"].to_i, date_hash1["(2i)"].to_i, date_hash1["(3i)"].to_i, date_hash1["(4i)"].to_i, date_hash1["(5i)"].to_i,"+0000")
	puts @event_time

	new_emp_ingred = "ingredient" + @emp_ingred.length.to_s
	new_emp_q = "q" + @emp_ingred.length.to_s
	@emp_ingred << new_emp_ingred
	@emp_q << new_emp_q
	@ing <<""
	@qua <<""
	
	render "e2gather/new_user_event"
	return 
    end
    
    @current_user = User.find(session[:user_id])
    puts "Current user " + @current_user.name
    @event = Event.new
    @event.host = @current_user.id

    #check event's name and location length
    if params[:name].length <=255
      @event.name = params[:name]
    else
      errorpage 'Name for event is too long,should be less than 255'
      return
    end

    if params[:location].length <= 255
      @event.location = params[:location]
    else
      errorpage 'Location for event is too long,should be less than 255'
      return
    end

    @event.event_id = Time.now.to_i 
    # Status: Pending, Confirmed, Cancelled
    @event.status = "Pending"
     
    # Set date and time
    puts "Show params: " + params.to_s()
    date_hash = params[:date_time]
    
    #check valid number of dates in month
    if(date_hash["(1i)"].to_i % 4 == 0) && (date_hash["(2i)"].to_i == 2)&& (date_hash["(3i)"].to_i > 29)
      errorpage 'Not a valid date'
      return
    end
    if(date_hash["(1i)"].to_i % 4 != 0) && (date_hash["(2i)"].to_i == 2)&& (date_hash["(3i)"].to_i > 28)
      errorpage 'Not a valid date'
      return
    end

    month_30days = Array.new
    month_30days = [4,6,9,11]

    month_31days = Array.new
    month_31days = [1,3,5,7,8,10,12]

    for i in 0..month_30days.length-1
      if (date_hash["(2i)"].to_i == month_30days[i]) && (date_hash["(3i)"].to_i > 30)
        errorpage 'Not a valid date'
        return
      end
    end

    for i in 0..month_31days.length-1
      if (date_hash["(2i)"].to_i == month_31days[i]) && (date_hash["(3i)"].to_i > 31)
        errorpage 'Not a valid date'
        return
      end
    end

    date = DateTime.new(date_hash["(1i)"].to_i, date_hash["(2i)"].to_i, date_hash["(3i)"].to_i, date_hash["(4i)"].to_i, date_hash["(5i)"].to_i)
    @event.date_time = date

    #check date and time is not passed
    if Time.now.to_i > @event.date_time.to_i
      errorpage 'Event time has passed'
      return
    end
    
    @emp_ingred = session[:emp_ingred]
    @emp_q = session[:emp_q]	
    @ing = session[:ing]
    @qua = session[:qua]	
	 
    ingredient_list =[]
    # check if ingredient quantity is valid
    for i in 0..@emp_ingred.length-1
      if ((is_number(params[@emp_q[i]]) )&&( params[@emp_q[i]].to_i > 0)&&( params[@emp_q[i]].to_i <= 10000))
        ingredient_list << Ingredient.new( :name=> params[@emp_ingred[i]], :ingredient_id =>0, :quantity=>params[@emp_q[i]],  :unit=>0, :user_id=> 0)
      else
        session[:emp_ingred] = nil
        session[:emp_q] = nil 
        session[:ing] = nil
        session[:qua] = nil
        errorpage "Invalid input in ingredients"
        return
      end
    end
    # Add ingredient and guest to database
    @event.ingredient_list = ingredient_list
    @event.guest_list = ""
    @event.accept = 0
    @event.reject = 0
    @event.unconfirmed = ""
 
    puts "Check event id: " + @event.event_id.to_s()
     
    if @event.save
      session[:emp_ingred] = nil
      session[:emp_q] = nil
      redirect_to '/e2gather/loginFacebook'
    else
      errorpage 'Problem saving event. Please fill all fields with appropriate inputs'
    end
  end
     
  def render_ingredient_page 
    render "e2gather/new_ingredient"
  end

  def create_ingredient
    if session[:user_id].nil?
      puts "Error: no user"
      loginFacebook
    end

    @current_user = User.find(session[:user_id])
    @ingredient = Ingredient.new
    @ingredient.user_id = @current_user.id
    @ingredient.name = params[:name];
    @ingredient.quantity = params[:quantity]
    @ingredient.unit = params[:unit]
    @ingredient.ingredient_id =  Time.now.to_i
    
    #check valid quantity for ingredient
    if params[:quantity].to_i <=0 || params[:quantity].to_i > 10000
      errorpage 'Quantity is invalid'
      return
    end

    if @ingredient.save
      redirect_to "/e2gather/loginFacebook"
    else 
      errorpage 'Problem saving ingredient. Please fill all fields with appropriate inputs'
    end
  end

  def show_ingredient
    @ingredient = Ingredient.find(params[:id])
  end
  
  def edit_ingredient
     @ingredient = Ingredient.find(params[:id])
  end
  
  def update_ingredient
    @ingredient = Ingredient.find(params[:id])

    #check valid quantity for ingredient
    if (params[:quantity].to_i > 10000 || params[:quantity].to_i <= 0)
      errorpage 'Invalid quantity'
      return
    end

    if @ingredient.update_attributes(params.require(:ingredient).permit(:name, :quantity, :unit))    
      render "e2gather/show_ingredient"
    else  
      respond_to do |format|       
        format.html { render action: 'edit_ingredient' }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_ingredient
    @ingredient = Ingredient.find(params[:id])

     @ingredient.destroy
      redirect_to "/e2gather/loginFacebook"
    
  end

  def errorpage(error_message)
    flash[:error] = error_message
    session[:emp_ingred] = nil
    session[:emp_q] = nil
    render 'e2gather/error_page'
  end
			
  def errorpagenotfound
    flash[:error] = 'Page Not Found!'
    session[:emp_ingred] = nil
    session[:emp_q] = nil
    render 'e2gather/error_page'
  end
  
  def getFriendList
    friend_e2gather = Array.new
    @friends.each do |f|
      if User.where(user_id: (f["id"])).exists?
        puts "find friend !"
        friend_e2gather << f
      else
        puts "attempt to invite friends joining e2gather"
        #@api.put_wall_post("Test123", {}, f["id"], {});
      end
    end
    return friend_e2gather
  end
end


	
