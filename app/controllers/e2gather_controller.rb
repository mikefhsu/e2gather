#require 'net/smtp'
#require 'tlsmail'
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
 
      @ingredient_list = Ingredient.all
      @event_list = Event.all
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

  def send_email(to,opts={})
    opts[:server]      ||= 'smtp.gmail.com'
    opts[:from]        ||= 'lechangusa@gmail.com'
    opts[:from_alias]  ||= 'lechangusa@gmail.com'
    opts[:subject]     ||= "You need to see this"
    opts[:body]        ||= "Important stuff!"

    msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE
    smtp = Net::SMTP.new 'smtp.gmail.com', 587
    smtp.enable_tls()
    smtp.start('smtp.gmail.com','lechangusa@gmail.com', 'fortunegod100%', :login) do |smtp|
      smtp.send_message msg, opts[:from], 'changle@live.cn'
    end
  end

  
  
  def sendmail
     my_email = params['my_email']
	 #name =  params['name']
	 id =  params['id']
	 email = User.find(id)['email']
	 #puts name
	 #puts email
	 #puts "kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk"
     #puts @my_email
	 UserMailer.welcome_email(session[:user] ,email, my_email).deliver
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
    # Generate event id for event
    @event.event_id = Time.now.to_i 
    # Status: 0-pending, 1-confirmed, 2-cancelled
    @event.status = 0

    # Set host, name, and location     
    @event.host = @current_user.name
    @event.name = params[:name]
    @event.location = params[:location]
     
    #Set date
    puts "Show params: " + params.to_s()
    date_hash = params[:date_time]
    date = DateTime.new(date_hash["(1i)"].to_i, date_hash["(2i)"].to_i, date_hash["(3i)"].to_i, date_hash["(4i)"].to_i, date_hash["(5i)"].to_i)
    @event.date_time = date

    #Temporarily collect ingredient and guest in this way
    ingredient = params[:ingredient]
    event_ingredient = Ingredient.select("user_id").where(name: ingredient)
    ingredient_list = []
    guest_list = [] 
    event_ingredient.each do |i|
      if session[:friend_list].nil? 
        puts "session[:friend_list] is nil"
      else
        session[:friend_list].each do |f|
          if f["id"] == i["user_id"]
            puts "f=" + f["id"] + "   i=" + i["user_id"] + " -> MATCH"
            ingredient_list << ingredient
            guest_list << f["id"]
          else 
            puts "f=" + f["id"] + "   i=" + i["user_id"] + " -> NO MATCH"
          end
        end
        puts "ingredient_list " + ingredient_list.to_sentence
        puts "guest_list " + guest_list.to_sentence
        @event.ingredient_list = ingredient_list
        @event.guest_list = guest_list
      end
    end
    redirect_to "e2gather/select_guests"
     
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
      respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

#  def show_ingredients
 #   if session[:user].nil?
 #     puts "Error: no user"
  #    loginFacebook
 #   end
  #  ingredientlist = Array.new
  #  @ingrdients.each do |i|
   #   if Ingredient.where(user_id: (i["id"])).exists?
    #    puts i.name
    #    ingredientlist << i
    #  else
     #   puts "No ingredients in the refrigerator!"
   #   end
   # end
  #  return ingredientlist
 # end



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

	
