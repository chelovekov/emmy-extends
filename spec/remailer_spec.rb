require "spec_helper"
require "emmy_extends/remailer"

describe EmmyExtends::Remailer do
  around do |example|
    EmmyMachine.run_block &example
  end

  it "sends email" do
    req = EmmyExtends::Remailer::Request.new(
      emails: [{
        to: '...',
        from: '...',
        content: 'Hello, Mail Tester!'
      }],
      options: {
        host: 'smtp.gmail.com',
        port: 587,
        username: '...',
        password: '...'
      }
    )
    res = req.op.sync
    expect(res.success?).to be(true)
  end
end
