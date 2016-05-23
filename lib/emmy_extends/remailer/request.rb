module EmmyExtends
  class Remailer::Request
    include ModelPack::Document
    
    array :emails, class_name: Remailer::Email
    object :options, class_name: Remailer::Options

    def operation
      @operation ||= new_operation
    end

    def new_operation
      EmmyExtends::Remailer::Operation.new(self)
    end

    alias op operation

    def sync
      operation.sync
    end

    #<<<
  end
end
