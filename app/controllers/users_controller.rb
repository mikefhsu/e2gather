class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def compose_guest_list(guest_list)
    if guest_list.length == 0
      return ""
    end

    if guest_list.length == 1
      return guest_list[0]
    end
    
    ret = ""
    guest_list.each {|tmp|
      ret = ret + tmp + ","
    }
    #Remove last ,
    ret = ret[0...-2]
    return ret
  end

  def update_invitation
    puts "Check params " + params.to_s

    if Event.where(id: params[:e_id]).exists?
      @current_event = Event.find(params[:e_id])
      @current_user = User.find(session[:user_id])

      if @current_event.host == @current_user.name
        render "users/you_host"
        return
      end

      unconfirmed = @current_event.unconfirmed.split(",")
      u_idx = unconfirmed.index(@current_user.name)

      if !u_idx.nil?
        if params[:option] == "1"
          @current_event.accept += 1
        else
          @current_event.reject += 1
          
          #Remove reject guest
          guest_list = @current_event.guest_list.split(",")
          g_idx = guest_list.index(@current_user.name)
          
          #g_idx should not be nil actually
          guest_list.delete_at(g_idx)
          puts "After deletion: " + guest_list.to_s
          @current_event.guest_list = compose_guest_list(guest_list)
        end
        
        #Update unconfirmed list
        unconfirmed.delete_at(u_idx)
        @current_event.unconfirmed = compose_guest_list(unconfirmed)
      end

      puts "Update accept " + @current_event.accept.to_s
      puts "Update reject " + @current_event.reject.to_s
      puts "Update unconfirmed " + @current_event.unconfirmed.to_s
      puts "Update guest_list " + @current_event.guest_list.to_s
            
      if @current_event.save
        #Send message to host
        host_user = User.find_by name: @current_event.host
        
        if params[:option] == "1"
          @current_event.notify_host(host_user, @current_user.name, 1)
        else
          @current_event.notify_host(host_user, @current_user.name, 0)
        end

        if @current_event.unconfirmed.length == 0
          @current_event.notify_host(host_user, nil, 2)
        end  
        
        redirect_to "/e2gather/loginFacebook"
        return
      end
    end
    redirect_to "/e2gather/errorpage"
    return
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:user_id, :name, :email)
    end
end
