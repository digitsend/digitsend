module DigitSend
  class MissingPhoneNumbers < DigitSend::Exception
    def email_addresses
      data["email_addresses"]
    end
  end
end
