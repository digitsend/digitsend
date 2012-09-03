module DigitSend
  class Message
    def initialize
      @attachments = []
      @phone_numbers = {}
    end

    def self.send(&block)
      new.tap { |m| yield(m) }.send
    end

    attr_accessor :to, :cc, :subject, :body, :phone_numbers

    def add_file(filename, data = nil)
      @attachments << [ filename, data ]
    end

    def send
      Client.call '/messages', message: {
        to: to,
        cc: cc,
        subject: subject,
        body: body,
        s3_file_uuids: s3_file_uuids,
        phone_numbers: phone_numbers
      }
    end

    private

      def s3_file_uuids
        @attachments.collect do |filename, data|
          Client.upload_s3_file(filename, data)
        end
      end
  end
end
