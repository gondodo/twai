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
