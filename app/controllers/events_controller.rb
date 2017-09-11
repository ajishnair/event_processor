class EventsController < ApplicationController
	before_action :set_user, only: [:show]
 #respond_to :json

  def create
    render status: :bad_request, :json => { :msg => "Device ID param not found."} and return unless params[:device_id].present?
    @user = User.find_by(:device_id => params[:device_id]) rescue nil
    render status: :not_found, :json => { :msg => "Invalid device ID."} and return unless @user.present?

    for event in params[:events]
      event.permit!
      @event = Event.new(event)
      if @event.is_blocked(params[:device_id])
        @event.increment_counter(params[:device_id])
        logger.info("Event blocked : " + params[:device_id] + " " + @event.name)
      else
        @event.user_id = @user.id
        @event.created_at = params[:ts] if params[:ts].present?
        if !@event.save
          logger.error("Failed to save event : " + @event)
        end
      end
    end

    render status: :created, :json => { :msg => "Events saved successfully."}
  end

  def show
    if @user.present?
      events = @user.events.order_by(:created_at => 'asc')
      render json: events.as_json(:only => [:name, :created_at, :info]), status: :ok
    else
      render status: :not_found, :json => { :msg => "Device ID not found."}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(:device_id => params[:id]) rescue nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit!
    end
end
