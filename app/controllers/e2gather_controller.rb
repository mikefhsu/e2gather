class E2gatherController < ApplicationController
  #@db_info
  #@db_fetch_result
  def index
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
    render :text => "You've logged out!"
  end
	 
  def loginFacebook 
    if params[:code]
      # acknowledge code and get access token from FB
      session[:access_token] = session[:oauth].get_access_token(params[:code])
    end		
    
    #re-direct to E2Gather home page 
		  
    # auth established, now do a graph call:  
    @api = Koala::Facebook::API.new(session[:access_token])
    session[:api] = @api
    begin
      @graph_data = @api.get_object("/me/statuses", "fields"=>"message")
      user = @api.get_object("me")

      puts "Get me " + user.to_s()
			
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
      
      session[:user] = @current_user       
      puts "Check instance var current_user " + session[:user].name	
      
      @friends = @api.get_connections(user["id"], "friends")
      puts "Facebook friends: " + @friends.to_s()     
 
      @ingredient_list = Ingredient.find(:all)
      @friend_list =getFriendList 
      @friend_list.each do |f|
        puts f['id']
      end
      session[:friend_list] = @friend_list
    rescue Exception=>ex
      puts ex.message
    end

    respond_to do |format|
      format.html {   }
    end
    
    puts "Check object " + self.to_s
  end

  def ingre
     @my_input = params['my_input']
     puts @my_input
     redirect_to action: :loginFacebook
  end
 
  def render_event_page
    render "e2gather/new_user_event"
  end
  
  def create_user_event
     puts "Check object " + self.to_s
     puts "Test create_user_event"

     if session[:user].nil?
      puts "No current user"
      loginFacebook
     end
     
     @current_user = session[:user]
     puts "Current user " + @current_user.name
     @event = Event.new
     @event.host = @current_user.name
     @event.name = params[:name]
     @event.location = params[:location]
     
     #Set date
     puts "Show params: " + params.to_s()
     date_hash = params[:date_time]
     date = DateTime.new(date_hash["(1i)"].to_i, date_hash["(2i)"].to_i, date_hash["(3i)"].to_i, date_hash["(4i)"].to_i, date_hash["(5i)"].to_i)

     @event.date_time = date

     #Temporarily collect ingredient and guest in this way
     ingredient_list = params[:ingredient1] + "," + params[:ingredient2] + "," + params[:ingredient3]
     guest_list = params[:guest1] + "," + params[:guest2] + "," + params[:guest3]

     puts "ingredient_list " + ingredient_list
     puts "guest_list " + guest_list
     @event.ingredient_list = ingredient_list
     @event.guest_list = guest_list

     #Generate event id for event
     t = Time.now.to_i
     @event.event_id = t
     
     #0 for incomplete, 1 for complete
     @event.status = 0
     
     puts "Check event id: " + @event.event_id.to_s()
     
     if @event.save
       redirect_to "/e2gather/loginFacebook"
     else
       respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
       end
     end
  end
     
  def render_ingredient_page 
    render "e2gather/new_ingredient"
  end

  def create_ingredient
    if session[:user].nil?
      puts "Error: no user"
      loginFacebook
    end

    @current_user = session[:user]
    @ingredient = Ingredient.new
    @ingredient.user_id = @current_user.id
    @ingredient.name = params[:name];
    @ingredient.quantity = params[:quantity]
    @ingredient.unit = params[:unit]

    ingre_id = Time.now.to_i
    @ingredient.ingredient_id = ingre_id

    if @ingredient.save
      redirect_to "/e2gather/loginFacebook"
    else 
      redirect_to "/e2gather/loginFacebook"
  end
end

  def show_ingredient
    @ingredient = Ingredient.find(params[:id])
  end
  
  def update_ingredient
    @ingredient = Ingredient.find(params[:id])
    @ingredient.name = params[:name];
    @ingredient.quantity = params[:quantity]
    @ingredient.unit = params[:unit]

      if @ingredient.save
	       redirect_to :action => 'show_ingredient', :id => @ingredient
      else
         
         render :action => 'update_ingredient'
      end
  end


     #respond_to do |format|
     # if @event.save
     #   format.html { redirect_to @event, notice: 'Event was successfully created.' }
     #   format.json { render action: 'show', status: :created, location: @event }
     #   redirect_to "e2gather/loginFacebook"
     # else
     #   format.html { render action: 'new' }
     #   format.json { render json: @event.errors, status: :unprocessable_entity }
     # end
     #end
	
  def sendInvitation
	  # send message
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


	
