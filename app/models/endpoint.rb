#
# Represents endpoint model as defined in the task
# #
class Endpoint < ApplicationRecord
  validates_presence_of :path, :verb
  # in accordance with RFC 7231
  validates :verb, inclusion: { in: %w[GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE] }
  # custom methods to check correct syntax of path and response parameters
  validate :check_path_correctness, :check_response_correctness

  # path and verb must to be unique for that to work, even though the task does not specify that
  # validates_uniqueness_of :path, scope: :verb

  # method to make sure path has the /path context and matches url path pattern
  def check_path_correctness
    errors.add :path, 'Must match url path pattern' unless %r{(/(\S)+)+}.match(path)
  end

  # method to check correct structure of response
  # mandatory fields:
  # code: must be integer
  # headers: must be key-value hash
  # body: must be string, must be parseable JSON, otherwise message will not be rendered correctly
  def check_response_correctness
    if response.empty?
      errors.add :response, 'Must not be empty.'
      return
    end
    check_response_code
    check_response_headers
    check_response_body
  end

  def check_response_code
    code = response['code']
    errors.add :response_code, 'Must be an integer.' if code.nil? || !code.is_a?(Integer)
  end

  def check_response_headers
    headers = response['headers']
    errors.add :response_headers, 'Must be an key-value hash.' if headers.nil? || !headers.is_a?(Hash)
  end

  def check_response_body
    body = response['body']
    # trick to check whether JSON string is valid and parseable
    is_unparseable = body.blank? || !body.is_a?(String) || (JSON.parse(body) rescue false) == false
    errors.add :response_body, 'Must be a string that can be parsed as JSON.' if is_unparseable
  end

  # helper method for rendering templates
  def filtered_attributes
    as_json(only: %i[verb path response], symbolize_names: true)
  end
end
