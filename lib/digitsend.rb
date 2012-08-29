require "digitsend/version"
require "net/http"
require "net/http/post/multipart"
require "json"

module DigitSend
  class Config
    class <<self
      @host = 'digitsend.com'
      @use_ssl = true

      attr_accessor :api_token
      attr_accessor :host
      attr_accessor :use_ssl
      attr_writer :port

      def port
        @port || use_ssl ? 443 : 80
      end
    end
  end

  class Message
    def initialize
      @attachments = []
      yield self
    end

    def self.send(&block)
      new(&block).send
    end

    attr_accessor :to, :cc, :subject, :body

    def add_file(path)
      @attachments << path
    end

    def send
      api_call '/api/messages', message: {
        to: to,
        cc: cc,
        subject: subject,
        body: body,
        s3_file_uuids: @attachments.collect { |path| s3_file_uuid(path) }
      }
    end

    private

      def s3_file_uuid(path)
         response = create_s3_file(File.basename(path))
         upload_to_s3(path, URI.parse(response["url"]), response["fields"])
         finalize_s3_file(response["uuid"])
         response["uuid"]
      end

      def create_s3_file(name)
        api_call '/api/s3_files', { name: name }
      end

      def upload_to_s3(path, url, fields)
        req = Net::HTTP::Post::Multipart.new \
          url.to_s,
          fields.merge("file" => UploadIO.new(File.open(path), "binary/octet-stream", path))

        n = Net::HTTP.new(url.host, url.port)
        n.use_ssl = true
        n.verify_mode = OpenSSL::SSL::VERIFY_NONE

        n.start do |http|
          http.request(req)
        end
      end

      def finalize_s3_file(uuid)
        api_call "/api/s3_files/#{uuid}/finalize", nil
      end

      def api_call(path, params)
        http = Net::HTTP.new(Config.host, Config.port)
        http.use_ssl = Config.use_ssl

        response = http.post path, params && params.to_json,
          'Content-Type' => 'application/json',
          'Accept' => 'application/vnd.digitsend.v1',
          'Authorization' => %Q[Token token="#{Config.api_token}"]

        response.body.empty? ? nil : JSON.parse(response.body)
      end
  end
end
