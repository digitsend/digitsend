require "net/http"
require "net/http/post/multipart"
require "json"

module DigitSend
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
          Client.call '/api/s3_files', s3_file: { name: File.basename(name) }
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
end