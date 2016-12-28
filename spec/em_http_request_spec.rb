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
    expect(response.headers["Server"]).to eq("nginx")
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
    expect(response.headers["Server"]).to eq("nginx")
    expect(response.body.empty?).to be false
  end

  it "should send http get with params to httpbin.org" do
    request = EmmyHttp::Request.new(
      type: 'get',
      url: 'http://httpbin.org',
      path: '/bytes{/bytes}',
      params: {
        bytes: 1024
      }
    )
    operation = EmmyHttp::Operation.new(request, EmmyExtends::EmHttpRequest::Adapter.new)
    response = operation.sync

    expect(response.status).to be 200
    expect(response.headers).to include("Content-Type")
    expect(response.headers["Server"]).to eq("nginx")
    expect(response.body.empty?).to be false
  end

  it "should send http get with params to httpbin.org" do
    request = EmmyHttp::Request.new(
      type: 'POST',
      url: 'http://httpbin.org',
      path: '/post',
      json: {points: [{x:5, y:6}, {x:3, y:2}]}

    )
    operation = EmmyHttp::Operation.new(request, EmmyExtends::EmHttpRequest::Adapter.new)
    response = operation.sync

    expect(response.status).to be 200
    expect(response.content_type).to eq("application/json")
    expect(response.content["json"]).to include('points' => [{'x' => 5, 'y' => 6}, {'x' => 3, 'y' => 2}])
  end
=begin
  it "sends two request one by one over single connection" do
    req1 = EmmyHttp::Request.new(
      type: 'get',
      url: 'http://httpbin.org/get',
      query: {param: 5},
      keep_alive: true
    )

    req2 = req1.copy
    # change query params
    req2.query = {param: 10}
    op1 = EmmyHttp::Operation.new(req1, EmmyExtends::EmHttpRequest::Adapter.new)
    res1 = op1.sync

    op2 = EmmyHttp::Operation.new(req2, EmmyExtends::EmHttpRequest::Adapter.new, op1.connection)
    res2 = op2.sync

    expect(res1).to_not be nil
    expect(res1.status).to be 200
    expect(res2).to_not be nil
    expect(res2.status).to be 200
  end
=end
end
