class Api::V1::EventsController < ApplicationController
  before_action :set_klass
  before_action :require_user, only: [:create, :rsvp]
  before_action :set_event, only: [:invitees, :rsvps, :users, :rsvp]


  # GET /api/v1/events?start_date=&enddate=
  def index
    if params[:start_date].present? && params[:end_date].present?
      start_date, end_date = Date.parse(params[:start_date]), Date.parse(params[:end_date])
      @records = @klass.in_date_range(start_date: start_date, end_date: end_date)
    end
    super
  end

  # POST /api/v1/events
  def create
    @event = @klass.create!(filtered_params)
    ::EventUser.create!(event_id: @event.id, user_id: current_user.id, role: :creator)

    render json: @event, status: :created
  end

  # GET api/v1/events/:id/invitees
  def invitees
    render json: @event.users
  end

  # GET api/v1/events/:id/rsvps
  def rsvps
    render json: @event.rsvps
  end

  # PUT api/v1/events/:id/users?ids[]=&ids[]=
  def users
    user_ids = params[:ids] - EventUser.where(event_id: @event.id).pluck(:user_id)
    entries = user_ids.map { |user_id| {event_id: @event.id, user_id: user_id, created_at: Time.now, updated_at: Time.now} }

    EventUser.insert_all! entries
    head :no_content
  end

  # PUT api/v1/events/:id/rsvp?value
  def rsvp
    event_user = @event.rsvp(user_id: current_user.id)

    return head :unauthorized unless event_user

    event_user.update!(rsvp: params[:value])
    head :no_content
  end

  private

  def filtered_params
    params.permit(:title, :starttime, :description, :allday, :endtime)
  end

  def require_user
    head :unauthorized unless current_user
  end

  def set_klass
    @klass = Event
  end

  def set_event
    @event = ::Event.find(params[:id]) unless @event
  end
end
