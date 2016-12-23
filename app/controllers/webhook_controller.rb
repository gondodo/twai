class WebhookController < ApplicationController
  #  Lineからのcallbackか認証
  protect_from_forgery with: :null_session

  CHANNEL_SECRET = ENV['CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['CHANNEL_ACCESS_TOKEN']
  DOCOMO_API_KEY = ENV['DOCOMO_API_KEY']

  def callback
    unless is_validate_signature
      render :nothing => true, status: 470
    end

    # event = params["events"][0]
    # event_type = event["type"]
    # replyToken = event["replyToken"]
    #
    # case event_type
    # when "message"
    #   input_text = event["message"]["text"]
    #   tweet = Bird.search(input_text)
    #   output_text = tweet
    # end
    #

    logger.info(params)
    result = params["events"][0]
    logger.info({from_line: result})
    # if result['content']['opType'].present?
    #
    #   mid = result['content']['params'][0]
    #
    #   client = LineClient.new(CHANNEL_ID, CHANNEL_SECRET, CHANNEL_MID, OUTBOUND_PROXY)
    #   res = client.profile(mid)
    #
    #   if res.status == 200
    #     logger.info({success: res})
    #
    #     display_name = res.body['contacts'][0]['displayName']
    #
    #     opType = result['content']['opType']
    #     case opType
    #     when 4 then
    #       user = User.create_with(display_name: display_name, status: 4).find_or_create_by(mid: mid)
    #       user.display_name = display_name
    #       user.status = 4
    #       user.save!
    #     when 8 then
    #       user = User.create_with(display_name: display_name, status: 8).find_or_create_by(mid: mid)
    #       user.display_name = display_name
    #       user.status = 8
    #       user.save!
    #     else
    #     end
    #   else
    #     logger.info({fail: res})
    #   end
    # else
      text_message = result['content']['text']
      from_mid = result['content']['from']

      last_message = Message.last.text_message

      user = User.find_by(mid: from_mid)

      Message.create(user_id: user.id, text_message: text_message)

      ### ここから修正 ###
      docomo_client = DocomoClient.new(DOCOMO_API_KEY)
      response = nil
      last_dialogue_info = LastDialogueInfo.find_by(mid: from_mid)
      if last_dialogue_info.nil?
        response =  docomo_client.dialogue(text_message)
        last_dialogue_info = LastDialogueInfo.new(mid: from_mid, mode: response.body['mode'], da: response.body['da'], context: response.body['context'])
      else
        response =  docomo_client.dialogue(text_message, last_dialogue_info.mode, last_dialogue_info.context)
        last_dialogue_info.mode = response.body['mode']
        last_dialogue_info.da = response.body['da']
        last_dialogue_info.context = response.body['context']
      end
      last_dialogue_info.save!
      message = response['utt']
      ### ここまで修正 ###

      client = LineClient.new(CHANNEL_ID, CHANNEL_SECRET, CHANNEL_MID, OUTBOUND_PROXY)
      res = client.send([from_mid], message)
      # res = client.reply(replyToken, output_text)

      if res.status == 200
        logger.info({success: res})
      else
        logger.info({fail: res})
      end
    # end

    render :nothing => true, status: :ok
  end

  private
  # verify access from LINE
  def is_validate_signature
    signature = request.headers["X-LINE-Signature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end
end
