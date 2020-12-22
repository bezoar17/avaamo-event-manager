module RequestSpecHelper

  # add api_v1 prefix
  def api_v1
    "/api/v1"
  end

  # Parse JSON response to ruby hash
  def json
    JSON.parse(response.body)
  end
end