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

  def update_invitation

    puts "Check params " + params.to_s

    if Event.where(id: params[:e_id]).exists?
      @current_event = Event.find(params[:e_id])
      @current_user = User.find(session[:user_id])

      if @current_event.host == @current_user.name
        render "users/you_host"
        return
      end

      guest_list = @current_event.guest_list.split(",")
     
      guest_list.each {|tmp|
        if tmp == @current_user.name

          if params[:option] == 1
            @current_event.accept += 1
          else
            @current_event.reject += 1
          end

          guest_list.delete(tmp)
          break
        end
      }

      new_guest_list = ""
      guest_list.each {|tmp|
        new_guest_list = new_guest_list + tmp
      }

      @current_event.guest_list = new_guest_list
      puts "New accept " + @current_event.accept.to_s
      puts "New guest_list " + @current_event.guest_list.to_s
      
      if @current_event.save
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
