#require 'net/smtp'
#require 'tlsmail'
class E2gatherController < ApplicationController
  #@db_info
  #@db_fetch_result
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
    render :text => "You've logged out!"
  end
  
  def loginFacebook 
    if params[:code] and session[:access_token].nil?
      # acknowledge code and get access token from FB
      session[:access_token] = session[:oauth].get_access_token(params[:code])
    end		
    
    #re-direct to E2Gather home page 
		  
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
      #end 
	  puts session[:friend_list].to_s()
	  if session[:friend_list] ==0 or session[:friend_list]==nil
      @friends = @api.get_connections(user["id"], "friends")
	  @friend_list =getFriendList 
	  session[:friend_list] = @friend_list
      puts "Facebook friends: " + @friends.to_s()     
      end
 
      #@event_list = Event.all 
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
    
    user_name = User.find(session[:user_id]).name
    all_list = Event.find_by_sql("SELECT * FROM events ORDER By events.date_time")
    @event_list = all_list.select{|tmp| tmp.host == user_name || tmp.guest_list.split(",").include?(user_name)}
    
    if @event_list.nil?
      @event_list = Array.new
    end
    
    puts "Check events: " + @event_list.to_s
  end
  
  def sendmsg
    my_email = params['my_email']
    id =  params['id']
    email = User.find(id)['email']
	  name = User.find(id)['name']
	  UserMailer.welcome_email(session[:user] ,email,name, my_email).deliver
    redirect_to action: :loginFacebook
  end
  
  def render_event_page
    @ing_list=[]
	@guest_list =''
	@guest_list << 'a'
	@guest_list1 = ["Dollar", "1"], ["Kroner", "2"]
    render "e2gather/new_user_event"
  end
  
  
  def pick_guest_page
    
	@current_event = Event.find(params[:e_id])
	
	    event_ingredient = @current_event.ingredient_list
    #ingredient_list = []
    #guest_list = [] 
    #event_ingredient.each do |i|
    #  if session[:friend_list].nil? 
    #    puts "session[:friend_list] is nil"
    #  else
    #    session[:friend_list].each do |f|
    #      if f["id"] == i["user_id"]
    #        puts "f=" + f["id"] + "   i=" + i["user_id"] + " -> MATCH"
    #        ingredient_list << ingredient
    #        guest_list << f["id"]
    #      else 
    #        puts "f=" + f["id"] + "   i=" + i["user_id"] + " -> NO MATCH"
	#		puts "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk"
    #      end
    #    end
    #  end
    # end
	#@guest_list1  << ["kkk", "3"]
   # guest_list1 = params[:g1]
   
  
    #redirect_to "/e2gather/loginFacebook"
  end
  
  def create_user_event
    puts "Check object " + self.to_s
    puts "Test create_user_event"

    if session[:user_id].nil?
     puts "No current user"
     loginFacebook
    end
    
    @current_user = User.find(session[:user_id])
    puts "Current user " + @current_user.name
    @event = Event.new
    @event.host = @current_user.name
    @event.name = params[:name]
    @event.location = params[:location]
    #puts 'mymymyumymymyumymymyumymymyumymymyumymymyumymymyumymymyumymymyumymymyumymymyumymymyu' + params[:guest]
    # Generate event id for event
    @event.event_id = Time.now.to_i 
    # Status: Pending, Confirmed, Cancelled
    @event.status = "Pending"
     
    # Set date and time
    puts "Show params: " + params.to_s()
    date_hash = params[:date_time]
    date = DateTime.new(date_hash["(1i)"].to_i, date_hash["(2i)"].to_i, date_hash["(3i)"].to_i, date_hash["(4i)"].to_i, date_hash["(5i)"].to_i)
    @event.date_time = date

    # Collect ingredient and guest
	ingredient_list =[]
     ingredient_list << Ingredient.new( :name=>  params[:ingredient1], :ingredient_id =>0, :quantity=> 0,  :unit=>0, :user_id=> 0)
      ingredient_list << Ingredient.new( :name=>  params[:ingredient2], :ingredient_id =>0, :quantity=> 0,  :unit=>0, :user_id=> 0)
 ingredient_list << Ingredient.new( :name=>  params[:ingredient3], :ingredient_id =>0, :quantity=> 0,  :unit=>0, :user_id=> 0)
 ingredient_list << Ingredient.new( :name=>  params[:ingredient4], :ingredient_id =>0, :quantity=> 0,  :unit=>0, :user_id=> 0)


    # Add ingredient and guest to database
    @event.ingredient_list = ingredient_list#.to_sentence
    #@event.guest_list = guest_list.to_sentence
    #@event.unconfirmed = guest_list.to_sentence
    @event.accept = 0
    @event.reject = 0
 
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

    ingre_id = Time.now.to_i
    @ingredient.ingredient_id = ingre_id

    if @ingredient.save
      redirect_to "/e2gather/loginFacebook"
    else 
      respond_to do |format|
        format.html { render action: 'create_ingredient' }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
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

  def errorpage
    render "e2gather/error_page"
  end
			
  def getFriendList
    friend_e2gather = Array.new
    @friends.each do |f|
      if User.where(user_id: (f["id"])).exists?
        puts "find friend !"
        friend_e2gather << f
      end
    end
    return friend_e2gather
  end
end	
