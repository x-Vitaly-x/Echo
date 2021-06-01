require 'test_helper'

class EndpointTest < ActiveSupport::TestCase
  def setup
    @endpoint = Endpoint.new(
      path: '/test', verb: 'GET',
      response: {
        code: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: { 'message': 'Hello, world' }.to_json
      }
    )
  end

  test 'can create valid endpoint' do
    @endpoint.save
    assert @endpoint.persisted?
  end

  test 'can not create endpoint with incorrect path' do
    @endpoint.path = 'test'
    @endpoint.save
    assert !@endpoint.errors[:path].empty?
    assert !@endpoint.persisted?
  end

  test 'can not create endpoint with incorrect verb' do
    @endpoint.verb = 'GETX'
    @endpoint.save
    assert !@endpoint.errors[:verb].empty?
    assert !@endpoint.persisted?
  end

  test 'can not create endpoint with incorrect response code' do
    @endpoint.response['code'] = 'xxx'
    @endpoint.save
    assert !@endpoint.errors[:response_code].empty?
    assert !@endpoint.persisted?
  end

  test 'can not create endpoint with incorrect response headers' do
    @endpoint.response['headers'] = 'xxx'
    @endpoint.save
    assert !@endpoint.errors[:response_headers].empty?
    assert !@endpoint.persisted?
  end

  test 'can not create endpoint with incorrect response body' do
    @endpoint.response['body'] = 0
    @endpoint.save
    assert !@endpoint.errors[:response_body].empty?
    assert !@endpoint.persisted?
  end

  test 'can not create endpoint with unparseable message' do
    @endpoint.response['body'] = '{"message": "xxx"'
    @endpoint.save
    assert !@endpoint.errors[:response_body].empty?
    assert !@endpoint.persisted?
  end
end
