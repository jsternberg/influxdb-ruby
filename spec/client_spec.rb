require "spec_helper"

describe InfluxDB::Client do
  subject(:client) { InfluxDB::Client.new }

  before(:each) do
    Excon.defaults[:mock] = true
  end

  after(:each) do
    Excon.stubs.clear
  end

  it "will ping the server" do
    Excon.stub({}, lambda do |params|
      expect(params[:path]).to eq("/ping")
      {version: "1.3"}
    end)
    status = client.ping
    expect(status).to include(:version)
  end
end
