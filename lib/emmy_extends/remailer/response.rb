module EmmyExtends
  class Remailer::Response
    attr_accessor :status

    def initialize(status)
      @status = status
    end

    def success?
      status == 250
    end
  end
end
