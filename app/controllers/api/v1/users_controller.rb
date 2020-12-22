class Api::V1::UsersController < ApplicationController
  before_action :set_klass
  before_action :set_user, only: [:availability, :events]

  # POST /api/v1/users
  def create
    @user = @klass.create!(filtered_params)

    render json: @user, status: :created
  end

  # GET api/v1/users/:id/availability?start_date=&enddate=&slot_size=
  def availability
    unless params[:start_date].present? && params[:end_date].present?
      render json: {error: "complete date range required"}, status: :bad_request and return
    end
    start_date, end_date = Date.parse(params[:start_date]), Date.parse(params[:end_date])
    render json: @user.availability(start_date, end_date, params[:slot_size]&.to_i)
  end

  # GET api/v1/users/:id/events?start_date=&enddate=
  def events
    if params[:start_date].present?
      start_date, end_date = Date.parse(params[:start_date]), (Date.parse(params[:end_date]) rescue nil)
      @records = @user.events.in_date_range(start_date: start_date, end_date: end_date)
    else
      @records = @user.events
    end

    render json: @records
  end

  private

  def set_klass
    @klass = User
  end

  def filtered_params
    params.permit(:username, :email, :phone)
  end

  def set_user
    @user = ::User.find(params[:id]) unless @user
  end
end
