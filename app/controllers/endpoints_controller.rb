#
# Endpoint controller needed to CRUD Endpoint objects, as well as display existing messages
# #
class EndpointsController < ApplicationController
  before_action :require_type, only: [:create]
  before_action :require_endpoint, only: [:update, :destroy]

  # for GET methods to list all endpoints
  def index
    @endpoints = Endpoint.order('created_at DESC')
    render('endpoints/index', formats: :json)
  end

  # for POST /endpoints to create new endpoint
  def create
    @endpoint = Endpoint.create(create_params)
    if @endpoint.save
      render('endpoints/show', formats: :json, status: 201)
    else
      @errors = @endpoint.errors.full_messages.map { |message| {
        code: 'can_not_create',
        detail: message
      } }
      render('endpoints/errors', formats: :json, status: 422)
    end
  end

  # for PUT /endpoints/:id to update existing endpoint
  def update
    if @endpoint.update(update_params)
      render('endpoints/show', formats: :json, status: 200)
    else
      @errors = @endpoint.errors.full_messages.map { |message| {
        code: 'can_not_update',
        detail: message
      } }
      render('endpoints/errors', formats: :json, status: 422)
    end
  end

  # for DELETE /endpoints/:id to delete existing endpoint
  def destroy
    @endpoint.destroy
    render(json: nil, status: 204, formats: :json)
  end

  # method for rendering path of an endpoint, requires correct verb and path parameters
  def render_path
    @endpoint = Endpoint.find_by_verb_and_path(request.method, '/' + params.require(:path))
    if @endpoint
      render(
        json: JSON.parse(@endpoint.response.dig('body')), formats: :json, status: 200
      )
    else
      @errors = [
        {
          code: 'not_found',
          detail: "Requested page \'#{params.require(:path)}\' does not exist"
        }
      ]
      render('endpoints/errors', formats: :json, status: 404)
    end
  end

  private

  def create_params
    params.require(:data).require(:attributes).permit(
      :verb,
      :path,
      response: [:code, :body, headers: :json]
    )
  end

  def update_params
    params.require(:data).require(:attributes).permit(
      :verb,
      :path,
      response: [:code, :body, headers: :json]
    )
  end

  def type_param
    params.require(:data).require(:type)
  end

  # check to see that type parameter is given, as required in specification
  def require_type
    if type_param != 'endpoints'
      @errors = [
        {
          code: 'wrong_type',
          message: 'type parameter must be "endpoints"'
        }
      ]
      render('endpoints/errors', formats: :json, status: 500)
    end
  end

  # check to see that given endpoint id is correct
  def require_endpoint
    @endpoint = Endpoint.find_by_id(params.require(:id))
    if @endpoint.nil?
      @errors = [
        {
          code: 'not_found',
          detail: "Requested endpoint does not exist"
        }
      ]
      render('endpoints/errors', formats: :json, status: 404)
    end
  end
end
