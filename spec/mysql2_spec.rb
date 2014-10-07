require "spec_helper"
require "emmy_extends/mysql2"

describe EmmyExtends::Mysql2 do
  using EventObject

  let(:delay) { 1.0/3 }
  let(:query) { "SELECT sleep(#{delay}) as mysql2_query" }
  let(:db) { EmmyExtends::Mysql2::Client.new }

  context "fibers required" do
    around do |example|
      EmmyMachine.run_block &example
    end

    it "should query create operation" do
      operation = db.query query
      expect(operation).to be_a EmmyExtends::Mysql2::Operation
    end

    it "should execute query through sync" do
      operation = db.query query
      response = operation.sync
      expect(response).to be_a Mysql2::Result
    end
  end

  context "without fibres" do

    it "should execute query without fibers" do
      result = nil
      expect {
        EmmyMachine.run do
          operation = db.query query
          EmmyMachine.watch(*operation)
          operation.on :success do |response|
            EmmyMachine.stop
            result = response
          end

          operation.on :error do |error|
            EmmyMachine.stop
            raise error
          end
        end
      }.to_not raise_error

      expect(result).to be_a Mysql2::Result
    end
  end
end
