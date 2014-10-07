require "spec_helper"
require "emmy_extends/savon"

describe EmmyExtends::Savon do
  around do |example|
    EmmyMachine.run_block &example
  end

  it "should send SOAP request" do
    HTTPI.adapter = :emmy

    client = EmmyExtends::Savon.client(
      wsdl: File.expand_path("../ConvertTemperature.asmx.xml", __FILE__),
      convert_request_keys_to: :camelcase,
      open_timeout: 10,
      read_timeout: 10,
      log: false
    )
    operation = client.call(:convert_temp, :message => { :temperature => 30, :from_unit => "degreeCelsius", :to_unit => "degreeFahrenheit" })
    response = operation.sync

    fahrenheit = response.body[:convert_temp_response][:convert_temp_result]
    expect(fahrenheit).to eq("86")
    expect(response).to be_a(Savon::Response)
  end
end
