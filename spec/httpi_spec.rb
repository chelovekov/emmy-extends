require "spec_helper"
require "emmy_extends/httpi"

describe EmmyExtends::HTTPI do
  around do |example|
    EmmyMachine.run_block &example
  end

  it "should send request to github.com home page" do
    request = HTTPI.get("http://httpbin.org", :emmy)
    response = request.sync

    expect(response).to be_a(HTTPI::Response)
    expect(response.code).to be 200
    expect(response.headers).to include("Content-Type")
  end
end
