require "digitsend/version"
require "net/http"
require "json"

module DigitSend
  class Config
    class <<self
      attr_accessor :api_token
    end
  end

  class Message
    def initialize
      yield self
    end

    def self.send(&block)
      new(&block).send
    end

    attr_accessor :to, :cc, :subject, :body

    def send
      http = Net::HTTP.new('digitsend.com', 443)
      http.use_ssl = true

      payload = {
        message: {
          to: to,
          cc: cc,
          subject: subject,
          body: body
        }
      }

      http.post '/api/messages', payload.to_json,
        'Content-Type' => 'application/json',
        'Accept' => 'application/vnd.digitsend.v1',
        'Authorization' => %Q[Token token="#{Config.api_token}"]
    end
  end
end
