class LineClient
  END_POINT = "https://api.line.me"

  def initialize(channel_access_token, proxy = nil)
    @channel_access_token = channel_access_token
    @proxy = proxy
  end

  def post(path, data)
    client = Faraday.new(:url => END_POINT) do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
      conn.proxy @proxy
    end

    res = client.post do |request|
      request.url path
      request.headers = {
        'Content-type' => 'application/json',
        'Authorization' => "Bearer #{@channel_access_token}"
      }
      request.body = data
    end
    res
  end

  def reply(replyToken, text)
    messages = [{
        "type" => "text",
        "text" => text
    }]

    body = {
      "replyToken" => replyToken,
      "messages" => messages
    }
    post('/v2/bot/message/reply', body.to_json)
  end

  def reply_cost(replyToken, text)
    messages = [
      {
      "type": "template",
      "altText": "予算はいくらまで出すー？",
      "template": {
        "type": "carousel",
        "columns": [
            {
              "thumbnailImageUrl": "",
              "title": "予算",
              "text": "",
              "actions": [
                {
                  "type": "postback",
                  "label": "指定なし",
                  "text": "指定なし"
                  "data": "0"
                },
                {
                  "type": "postback",
                  "label": "〜１０００円",
                  "text": "〜１０００円",
                  "data": "1"
                },
                {
                  "type": "postback",
                  "label": "〜２０００円",
                  "text": "〜２０００円",
                  "data": "2"
                }
                ]
            },
            {
              "thumbnailImageUrl": "",
              "title": "予算",
              "text": "",
              "actions": [
                {
                  "type": "postback",
                  "label": "〜３０００円",
                  "text": "〜３０００円",
                  "data": "3"
                },
                {
                  "type": "postback",
                  "label": "〜４０００円",
                  "text": "〜４０００円",
                  "data": "4"
                },
                {
                  "type": "postback",
                  "label": "〜５０００円",
                  "text": "〜５０００円",
                  "data": "5"
                }
                ]
            },
            {
              "thumbnailImageUrl": "",
              "title": "予算",
              "text": "",
              "actions": [
                {
                  "type": "postback",
                  "label": "〜６０００円",
                  "text": "〜６０００円",
                  "data": "6"
                },
                {
                  "type": "postback",
                  "label": "〜８０００円",
                  "text": "〜８０００円",
                  "data": "7"
                },
                {
                  "type": "postback",
                  "label": "〜１００００円",
                  "text": "〜１００００円",
                  "data": "8"
                }
                ]
            },
            {
              "thumbnailImageUrl": "",
              "title": "予算",
              "text": "",
              "actions": [
                {
                  "type": "postback",
                  "label": "〜１５０００円",
                  "text": "〜１５０００円",
                  "data": "9"
                },
                {
                  "type": "postback",
                  "label": "〜２００００円",
                  "text": "〜２００００円",
                  "data": "10"
                },
                {
                  "type": "postback",
                  "label": "〜３００００円",
                  "text": "〜３００００円",
                  "data": "11"
                }
                ]
            }
            ]
          }
        }
    ]

    body = {
      "replyToken" => replyToken,
      "messages" => messages
    }
    post('/v2/bot/message/reply', body.to_json)
  end

  def reply_carousel(replyToken, tabelog)
    messages = [
      {
      "type": "template",
      "altText": "検索したで",
      "template": {
        "type": "carousel",
        "columns": [
            {
              "thumbnailImageUrl": tabelog[0].img_url,
              "title": "#{tabelog[0].rst_name} ★#{tabelog[0].hoshi}"[0, 39],
              "text": "夜：#{tabelog[0].dinner_cost}\ 昼：#{tabelog[0].lunch_cost} #{tabelog[0].text}"[0,59],
              "actions": [
                {
                  "type": "uri",
                  "label": "詳細を見る",
                  "uri": tabelog[0].url
                },
                {
                  "type": "postback",
                  "label": "もっと見る",
                  "data": "action=add&itemid=111"
                }
                ]
            },
            {
              "thumbnailImageUrl": tabelog[1].img_url,
              "title": "#{tabelog[1].rst_name} ★#{tabelog[1].hoshi}"[0, 39],
              "text": "夜：#{tabelog[1].dinner_cost}\ 昼：#{tabelog[1].lunch_cost} #{tabelog[1].text}"[0,59],
              "actions": [
                {
                  "type": "uri",
                  "label": "詳細を見る",
                  "uri": tabelog[1].url
                },
                {
                  "type": "postback",
                  "label": "もっと見る",
                  "data": "action=add&itemid=111"
                }
                ]
              },
              {
                "thumbnailImageUrl": tabelog[2].img_url,
                "title": "#{tabelog[2].rst_name} ★#{tabelog[2].hoshi}"[0, 39],
                "text": "夜：#{tabelog[2].dinner_cost}\ 昼：#{tabelog[2].lunch_cost} #{tabelog[2].text}"[0,59],
                "actions": [
                  {
                    "type": "uri",
                    "label": "詳細を見る",
                    "uri": tabelog[2].url
                  },
                  {
                    "type": "postback",
                    "label": "もっと見る",
                    "data": "action=add&itemid=111"
                  }
                  ]
                },
                {
                  "thumbnailImageUrl": tabelog[3].img_url,
                  "title": "#{tabelog[3].rst_name} ★#{tabelog[3].hoshi}"[0, 39],
                  "text": "夜：#{tabelog[3].dinner_cost}\ 昼：#{tabelog[3].lunch_cost} #{tabelog[3].text}"[0,59],
                  "actions": [
                    {
                      "type": "uri",
                      "label": "詳細を見る",
                      "uri": tabelog[3].url
                    },
                    {
                      "type": "postback",
                      "label": "もっと見る",
                      "data": "action=add&itemid=111"
                    }
                    ]
                  },
                  {
                    "thumbnailImageUrl": tabelog[4].img_url,
                    "title": "#{tabelog[4].rst_name} ★#{tabelog[4].hoshi}"[0, 39],
                    "text": "夜：#{tabelog[4].dinner_cost}\ 昼：#{tabelog[4].lunch_cost} #{tabelog[4].text}"[0,59],
                    "actions": [
                      {
                        "type": "uri",
                        "label": "詳細を見る",
                        "uri": tabelog[4].url
                      },
                      {
                        "type": "postback",
                        "label": "もっと見る",
                        "data": "action=add&itemid=111"
                      }
                      ]
                    }
            ]
          }
        }
    ]

    body = {
      "replyToken" => replyToken,
      "messages" => messages
    }
    post('/v2/bot/message/reply', body.to_json)
  end

end
