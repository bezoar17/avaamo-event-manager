class ApplicationController < ActionController::API

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_parameters

  include Authenticable

  def index
    @records ||= @klass.all
    render json: @records
  end

  def show
    render json: @klass.find(params[:id])
  end

  def not_found
    render json: {:error => "Entity not found"}, status: :not_found
  end

  def invalid_parameters(error)
    render json: {:error => error.message}, status: :bad_request
  end
end
