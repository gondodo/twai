class DocomoClient
  def initialize(api_key = nil)
    @api_key = api_key
  end

  def dialogue(message, mode = nil, context = nil)
    client = Docomoru::Client.new(api_key: @api_key)
    response = client.create_dialogue(message, {mode: mode, context: context, t: 20})
    return response
  end
end
