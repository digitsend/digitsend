module DigitSend
  class Message
    def initialize
      @to = []
      @cc = []
      @attachments = []
      @phone_numbers = {}
    end

    def self.send(&block)
      new.tap { |m| yield(m) }.send
    end

    def to(email, phone = nil)
      @to << email
      @phone_numbers[email] = phone if phone
    end

    def cc(email, phone = nil)
      @cc << email
      @phone_numbers[email] = phone if phone
    end

    def subject(text)
      @subject = text
    end

    def body(text)
      @body = text
    end

    def attach(filename, data = nil)
      @attachments << [ filename, data ]
    end

    def send
      Client.call '/messages', message: {
        to: @to.join(', '),
        cc: @cc.join(', '),
        subject: @subject,
        body: @body,
        s3_file_uuids: s3_file_uuids,
        phone_numbers: @phone_numbers
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
