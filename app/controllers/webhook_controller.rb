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

    logger.info(params)
    event = params["events"][0]
    # 送ってきたユーザID
    mid = event['source']['userId']
    replyToken = event['replyToken']
    # 取得したテキスト
    text_message = event["message"]["text"]

    if User.find_by(mid: mid) == nil
      user = User.create(mid: mid)
    else
      user = User.find_by(mid: mid)
    end
    Message.create(user_id: user.id, text_message: text_message)

    docomo_client = DocomoClient.new(DOCOMO_API_KEY)
    response = nil
    last_dialogue_info = LastDialogueInfo.find_by(mid: mid)

    # 一番最初のとき
    if last_dialogue_info.nil?
      response =  docomo_client.dialogue(text_message)
      last_dialogue_info = LastDialogueInfo.new(mid: mid, mode: response.body['mode'], da: response.body['da'], context: response.body['context'])
    # 2回め以降のとき
    else
      # 前回設定モード判定
      case last_dialogue_info.mode
      when "twitter"
        if text_message == "Twitter検索終わり"
          last_dialogue_info.mode = "dialog"
          message = "Twitterから検索やめるで"
        else
          message = Bird.search(text_message)
        end
      else
        if text_message == "Twitter検索"
          last_dialogue_info.mode = "twitter"
          message = "Twitterから検索するで"
        else
          response =  docomo_client.dialogue(text_message, last_dialogue_info.mode, last_dialogue_info.context)
          last_dialogue_info.mode = response.body['mode']
          last_dialogue_info.da = response.body['da']
          last_dialogue_info.context = response.body['context']
          message = response.body['utt']
        end
      end
      last_dialogue_info.save!
    end

    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, message)

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end

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
