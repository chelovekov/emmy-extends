module EmmyExtends
  class Remailer::Email
    include ModelPack::Document

    attribute :to
    attribute :from
    attribute :content
  end
end
