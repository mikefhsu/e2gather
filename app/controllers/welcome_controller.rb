require 'mysql'
require 'koala'
class WelcomeController < ApplicationController
  @db_info
  @db_fetch_result
  def index
	begin
		con = Mysql.new 'localhost', 'root', 'root'
		@db_info = "Database connection: " + con.get_server_info
		puts "Testing database connection " + con.get_server_info
		rs = con.query 'SELECT VERSION()'
		@db_fetch_result = "Database fetch result: " + rs.fetch_row.to_s
		puts "Try to fetch one row: " + rs.fetch_row.to_s
	rescue Mysql::Error => e
		puts e.errno
		puts e.error
	ensure
		con.close if con
	end

	session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + '/welcome/loginFacebook')
	@auth_url =  session[:oauth].url_for_oauth_code(:permissions=>"read_stream") 	
	puts session.to_s + "<<< session"

  	respond_to do |format|
			 format.html {  }
	end
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
			puts "Test graphdata #{@graph_data}"
			user = @api.get_object("me")
			@friends = @api.get_connections(user["id"], "friends")
		rescue Exception=>ex
			puts ex.message
		end
		
  
 		respond_to do |format|
		 format.html {   }			 
		end
  end
end
