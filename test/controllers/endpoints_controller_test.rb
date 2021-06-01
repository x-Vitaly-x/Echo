require "test_helper"

# Test to make sure controller methods work as required
class EndpointsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @correct_params = {
      data: {
        type: 'endpoints',
        attributes: {
          verb: 'GET',
          path: '/foo',
          response: {
            code: 200,
            headers: {},
            body: JSON.generate({ message: 'Hello world' })
          }
        }
      }
    }
  end

  test "must get index" do
    get "/endpoints"
    assert_response :success
    # body must be given in the exact specified format
    assert JSON.parse(response.body).dig('data').first.dig('type') == 'endpoints'
    # body must contain specified keys
    assert_equal JSON.parse(response.body).dig('data').first.dig('attributes').keys.sort, ["path", "verb", "response"].sort
  end

  test "must post create with correct params" do
    post "/endpoints", params: @correct_params, as: :json
    assert_response :success
  end

  test "must get error message on wrong params" do
    @correct_params[:data][:attributes][:path] = 'XXX'
    post "/endpoints", params: @correct_params, as: :json
    assert_response :unprocessable_entity
    # should give exactly one error
    assert JSON.parse(response.body)["errors"].length == 1
  end

  test "must be able update endpoint" do
    put "/endpoints/" + Endpoint.first.id, params: @correct_params, as: :json
    assert_response :success
    # body must be given in the exact specified format
    assert JSON.parse(response.body).dig('data').dig('type') == 'endpoints'
    # body must contain specified keys
    assert_equal JSON.parse(response.body).dig('data').dig('attributes').keys.sort, ["path", "verb", "response"].sort
  end

  test "must not update endpoint with incorrect data" do
    @correct_params[:data][:attributes][:path] = 'XXX'
    put "/endpoints/" + Endpoint.first.id, params: @correct_params, as: :json
    assert_response :unprocessable_entity
    # should give exactly one error
    assert JSON.parse(response.body)["errors"].length == 1
  end

  test "must not update incorrect endpoint" do
    put "/endpoints/XXX", params: @correct_params, as: :json
    assert_response :not_found
  end

  test "must be able to destroy existing endpoint" do
    endpoint_id = Endpoint.first.id
    delete "/endpoints/" + endpoint_id, as: :json
    assert_response :success
    assert_nil Endpoint.find_by_id(endpoint_id)
  end

  test "must not destroy wrong endpoint" do
    delete "/endpoints/XXX", params: @correct_params, as: :json
    assert_response :not_found
  end

  test "can render created endpoint path with correct method" do
    get Endpoint.first.path, as: :json

    assert_response :success
    # response body should be the defined message
    assert_equal response.body, Endpoint.first.response.dig('body')
  end

  test "can not render created endpoint path with incorrect method" do
    put Endpoint.first.path, as: :json

    assert_response :not_found
  end
end
