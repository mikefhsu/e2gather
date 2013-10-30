class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  
  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    puts "In show"
  end

  def view_event_page
    puts "Check params in view_event_page " + params.to_s 
    @current_event = Event.find(params[:e_id])
    @current_user = User.find(session[:user_id])

    if (@current_event.host == @current_user.name)
      render "events/view_host_event"
      return
    else
      render "events/view_event"
      return
    end
  end

  def finalized
    puts "Check params in finalized " + params.to_s
    @current_event = Event.find(params[:e_id])
    @current_user = User.find(session[:user_id])

    if (@current_event.host != @current_user.name)
      redirect_to "/e2gather/errorpage"
      return
    end

    guest_list = @current_event.guest_list.split(",")
    guest_objs = Array.new
    guest_list.each {|tmp|
      guest_objs << User.find_by(name: tmp)
    } 
    
    if (params[:option] == "1") 
      puts "Check guest obj: " + guest_objs.to_s
      if @current_event.unconfirmed.length == 0
        @current_event.status = "Confirmed"
        if @current_event.save
          @current_event.notify_guests(guest_objs, 1)
          flash[:event_msg] = "Event confirmed: " + @current_event.name + "!!"
          render "events/event_finalized"
        else
          render "e2gather/error_page"
        end
      else
        flash.now[:alert] = "Not every guest has responded!"
        render_to "e2gather/loginFacebook"
        return
      end
    else
      @current_event.status = "Cancelled"
      if @current_event.save
        @current_event.notify_guests(guest_objs, 0)
        flash[:event_msg] = "Event canceled: " + @current_event.name + "..."
        render "events/event_finalized"
      else
        render "e2gather/error_page"
      end
    end
  end

  # GET /events/new
  def new
    @event = Event.new
    @users = User.all
    @ingredients = Ingredient.all
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    
    #Generate event id for event
    t = Time.now.to_i
    @event.event_id = t

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @event }
      else
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      if Event.where(id: params["id"]).exists?
        @event = Event.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:event_id, :name, :location, :date_time, :host, :ingredient_list, :guest_list, :status)
    end
end
