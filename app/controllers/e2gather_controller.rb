class E2gatherController < ApplicationController
  @db_info
  @db_fetch_result
  def index
	session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + '/e2gather/loginFacebook')
	@auth_url =  session[:oauth].url_for_oauth_code(:permissions=>"email,publish_stream") 	
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
		begin
			@graph_data = @api.get_object("/me/statuses", "fields"=>"message")
			user = @api.get_object("me")
			
			if User.where(user_id: user["id"]).exists?
				@current_user = User.find(user["id"]);
			else 
				#@current_user = Users.new
				@current_user=User.new(:user_id => user["id"], :name => user["name"],:email => user["email"])
				@current_user.save
			end 
			

			
			
			@friends = @api.get_connections(user["id"], "friends")
            @friend_list =getFriendList  
			 
			#@friend_list.each do |f|
				#puts f['id']
			 #end
		rescue Exception=>ex
			puts ex.message
		end
		
  
 		respond_to do |format|
		 format.html {   }			 
		end
		
   end
	
		def sendInvitation
	
	
	end
	
	
	def getFriendList
			friend_e2gather = []
			@friends.each do |f|
				if User.where(user_id: (f["id"])).exists?
					#puts "find friend !"
					friend_e2gather << f
				end
			end
		return friend_e2gather
		end
end









