module DigitSend
  class Exception < ::Exception
    def initialize(hash)
      super(message)
      @data = hash["data"]
    end

    attr_reader :data
  end
end
