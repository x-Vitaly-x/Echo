#Readme

This it the solution to the endpoint task. Server can be started with `rails s` and will be able to carry out test 
scenarios provided.

###Installation

Make sure `Postgres` is installed as it is the database selected,
then run `bundle install`. After it succeeds, prepare the database with
`rake db:create` and `rake db:migrate`.

###Note

The server contains some generated data for Rails API project that I did not have time to clean up,
such as `cable.yml` various unneeded configuration options in `application.rb` and `develop.rb`. Please ignore them,
the only necessary logic is contained in `/app/models/endpoint.rb` and `/app/controllers/endpoints_controller.rb`
as well as in tests `/test/controllers/endpoints_controller_test.rb` and `/test/models/endpoint_test.rb`.

###Important note

Provided test scenarios had the following problems:

- Echo.rb library expected the wrong return parameter, which was not as it was described in the documentation:

    ```ruby
    new(id: data.dig(:id),
        verb: data.dig(:data, :attributes, :verb),
        path: data.dig(:data, :attributes, :path),
        response: data.dig(:data, :attributes, :response))
    ```
  Id will not be found, since technical description of the task specifies response to be

    ```json{
    "data": {
        "type": "endpoints",
        "id": "12345",
        "attributes": {
            "verb": "GET",
            "path": "/greeting",
            "response": {
              "code": 200,
              "headers": {},
              "body": "\\"{ \\"message\\": \\"Hello, world\\" }\\""
            }
        }
    }
    ```
  That since id is in the `data` field, response will be invalid, therefore the method `make_from_response` needs to be
  changed to
    ```ruby
    new(id: data.dig(:data, :id),
        verb: data.dig(:data, :attributes, :verb),
        path: data.dig(:data, :attributes, :path),
        response: data.dig(:data, :attributes, :response))
    ```
  
- Scenario test `refuse to update non existing endpoint`
  provided the server with a correct existing endpoint
  ```ruby
  def test_server_to_refuse_to_update_non_existing_endpoint
    response = api.update_endpoint(@endpoint.id, **@payload)

    exp = 404
    act = response.status_code

    assert_equal(exp, act)
  end
  ```
  Of course, the response was correct. In order for this test 
  scenario to be correct and do what it must do it hat to be updated to
  ```ruby 
  def test_server_to_refuse_to_update_non_existing_endpoint
    response = api.update_endpoint(SecureRandom.hex, **@payload)

    exp = 404
    act = response.status_code

    assert_equal(exp, act)
  end
  ```
  so that this time the id would actually be invalid. Likewise, 
  the test `test server to refuse invalid path` had to be updated to 
  ```ruby
  def test_server_to_refuse_invalid_path
    %w[` > < |].each do |char|
    @payload[:path] = char
    response = api.update_endpoint(@endpoint.id, **@payload)
    
        exp = 422
        act = response.status_code
  
        assert_equal(exp, act)
      end
  end
  ```
  This looks like a bug in the code, where `SecureRandom.hex` was
  put in the wrong place.
  

- Same thing with test `refuse to delete non-existing endpoint` 
  ```ruby 
  def test_server_to_refuse_to_delete_non_existing_endpoint
    response = api.delete_endpoint(@endpoint.id)

    exp = 404
    act = response.status_code

    assert_equal(exp, act)
  end
  ```
  `@endpoint` exists, therefore it needed to be changed to
  ```ruby
  response = api.delete_endpoint(SecureRandom.hex)
  ```
  
- Test `test_server_to_respond_with_empty_list` will give wrong response on
  second try and sometimes wrong response on first try, since given
  tests are order dependent and do not have ways of cleaning up the database.

Provided Rails tests for the application work as needed, the problem is solely with scenario tests.
