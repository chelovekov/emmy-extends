module EmmyExtends
  class Remailer::Options
    include ModelPack::Document

    attribute :host
    attribute :port
    attribute :username
    attribute :password
    attribute :use_tls, predicate: true, default: true
    attribute :require_tls, predicate: true, default: false
    attribute :debug, predicate: true, default: false
    attribute :timeout, default: 30
  end
end
