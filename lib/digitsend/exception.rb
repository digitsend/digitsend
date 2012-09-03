module DigitSend
  class Exception < ::Exception
    def initialize(hash)
      super(hash["message"])
      @data = hash["data"]
    end

    attr_reader :data
  end
end
