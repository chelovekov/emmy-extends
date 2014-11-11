require "spec_helper"
require "emmy_extends/em_http_request"

describe EmmyExtends::EmHttpRequest do

  around do |example|
    EmmyMachine.run_block &example
  end

  it "should send request to httpbin.org" do
    request = EmmyHttp::Request.new(
      type: 'get',
      url: 'http://httpbin.org'
    )
    operation = EmmyHttp::Operation.new(request, EmmyExtends::EmHttpRequest::Adapter.new)
    response = operation.sync

    expect(response.status).to be 200
    expect(response.headers).to include("Content-Type")
    expect(response.headers["Server"]).to eq("gunicorn/18.0")
    expect(response.body.empty?).to be false
  end

  it "should send https request to httpbin.org" do
    request = EmmyHttp::Request.new(
      type: 'get',
      url: 'https://httpbin.org'
    )
    operation = EmmyHttp::Operation.new(request, EmmyExtends::EmHttpRequest::Adapter.new)
    response = operation.sync

    expect(operation.to_a.first).to eq("tcp://httpbin.org:443")
    expect(response.status).to be 200
    expect(response.headers).to include("Content-Type")
    expect(response.headers["Server"]).to eq("gunicorn/18.0")
    expect(response.body.empty?).to be false
  end
end
