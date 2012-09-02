module DigitSend
  class Config
    @host = 'api.digitsend.com'
    @use_ssl = true

    class <<self
      attr_accessor :api_token
      attr_accessor :host
      attr_accessor :use_ssl
      attr_writer :port

      def port
        @port || ( @use_ssl ? 443 : 80 )
      end
    end
  end
end
