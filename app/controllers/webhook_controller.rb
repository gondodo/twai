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

    logger.info("text_message:#{text_message}")
    if User.find_by(mid: mid) == nil
      user = User.create(mid: mid)
    else
      user = User.find_by(mid: mid)
    end
    last_dialogue_info = LastDialogueInfo.find_by(mid: mid)
    Message.create(user_id: user.id, text_message: text_message, mode: last_dialogue_info.mode )
    docomo_client = DocomoClient.new(DOCOMO_API_KEY)
    response = nil


    # 一番最初のとき
    if last_dialogue_info.nil?
      logger.info("first step")
      response =  docomo_client.dialogue(text_message)
      last_dialogue_info = LastDialogueInfo.new(mid: mid, mode: response.body['mode'], da: response.body['da'], context: response.body['context'])
      last_dialogue_info.save!

    # 2回め以降のとき
    else
      logger.info("second step")

      # モード設定
      case text_message
        when "雑談", "しりとり"
          last_dialogue_info.mode = "dialog"
        when "話題検索"
          last_dialogue_info.mode = "twttr"
        when "グルメ検索"
          last_dialogue_info.mode = "grmt"
      end

      # メッセージ設定
      case last_dialogue_info.mode
        when "dialog", "srtr"
            response =  docomo_client.dialogue(text_message, last_dialogue_info.mode, last_dialogue_info.context)
            last_dialogue_info.mode = response.body['mode']
            last_dialogue_info.da = response.body['da']
            last_dialogue_info.context = response.body['context']
            message = response.body['utt']
            message.slice!("やけど") if last_dialogue_info.mode == "srtr"
        when "twttr"
          if text_message == "話題検索"
            message = "Twitterから検索するで！"
          else
            message = Bird.search(text_message)
          end
        when "grmt"
          message = Gourmet.search(text_message)
        end
      last_dialogue_info.save!
    end

    logger.info("success?")
    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    if message.kind_of?(Tabelog::ActiveRecord_AssociationRelation)
      res = client.reply_carousel(replyToken, message)
    else
      res = client.reply(replyToken, message)
    end

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
