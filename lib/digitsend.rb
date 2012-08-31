require "digitsend/version"
require "net/http"
require "net/http/post/multipart"
require "json"

module DigitSend
  class Config
    @host = 'digitsend.com'
    @use_ssl = true

    class <<self
      attr_accessor :api_token
      attr_accessor :host
      attr_accessor :use_ssl
      attr_writer :port

      def port
        @port || use_ssl ? 443 : 80
      end
    end
  end

  class Client
    class <<self
      def call(path, params)
        http = Net::HTTP.new(Config.host, Config.port)
        http.use_ssl = Config.use_ssl

        response = http.post path, params && params.to_json,
          'Content-Type' => 'application/json',
          'Accept' => 'application/vnd.digitsend.v1',
          'Authorization' => %Q[Token token="#{Config.api_token}"]

        response.body.empty? ? nil : JSON.parse(response.body)
      end

      def upload_s3_file(filename, data)
         response = create_s3_file(filename)

         upload_to_s3 \
           URI.parse(response["url"]),
           response["fields"],
           stream_for_data(filename, data)

         response["uuid"]
      end

      private

        def create_s3_file(name)
          Client.call '/api/s3_files', s3_file: { name: name }
        end

        def upload_to_s3(url, fields, stream)
          req = Net::HTTP::Post::Multipart.new \
            url.to_s,
            fields.merge("file" => UploadIO.new(stream, "binary/octet-stream"))

          n = Net::HTTP.new(url.host, url.port)
          n.use_ssl = true
          n.verify_mode = OpenSSL::SSL::VERIFY_NONE

          n.start do |http|
            http.request(req)
          end
        end

        def stream_for_data(filename, data)
          if data.nil?
            File.open(filename, "r")
          elsif data.is_a?(String)
            StringIO.new(data)
          else
            data
          end
        end
    end
  end

  class Message
    def initialize
      @attachments = []
    end

    def self.send(&block)
      new.tap { |m| yield(m) }.send
    end

    attr_accessor :to, :cc, :subject, :body

    def add_file(filename, data = nil)
      @attachments << [ filename, data ]
    end

    def send
      Client.call '/api/messages', message: {
        to: to,
        cc: cc,
        subject: subject,
        body: body,
        s3_file_uuids: s3_file_uuids
      }
    end

    private

      def s3_file_uuids
        @attachments.collect do |filename, data|
          Client.upload_s3_file(filename, data)
        end
      end
  end

  class Repository
    def self.upload(repo_name, path, filename, data)
      uuid = Client.upload_s3_file(filename, data)

      Client.call '/api/files/versions',
        repo_name: repo_name,
        path: path,
        repo_file_version: { s3_file_uuid: uuid }
    end
  end
end
