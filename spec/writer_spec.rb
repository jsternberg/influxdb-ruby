require "spec_helper"

describe InfluxDB::HTTPWriter do
  context "with the http writer" do
    subject(:client) do
      client = InfluxDB::Client.new
    end

    before(:each) do
      Excon.defaults[:mock] = true
    end

    after(:each) do
      Excon.stubs.clear
    end

    it "will write the data directly" do
      Excon.stub({}, lambda do |params|
        expect(params[:path]).to eq("/write")
        expect(params[:body]).to eq("foobar")
        expect(params[:query]).to be_empty
        {status: 204}
      end)
      n = client.writer.write("foobar")
      expect(n).to eq(6)
    end

    it "will set the database with db" do
      Excon.stub({}, lambda do |params|
        expect(params[:path]).to eq("/write")
        expect(params[:body]).to eq("foobar")
        expect(params[:query]).to eq("db" => "db0")
        {status: 204}
      end)
      n = client.writer(db: "db0").write("foobar")
      expect(n).to eq(6)
    end

    it "will set the database and retention policy with db/rp" do
      Excon.stub({}, lambda do |params|
        expect(params[:path]).to eq("/write")
        expect(params[:body]).to eq("foobar")
        expect(params[:query]).to eq("db" => "db0", "rp" => "rp0")
        {status: 204}
      end)
      n = client.writer(db: "db0", rp: "rp0").write("foobar")
      expect(n).to eq(6)
    end

    it "will set the database with database" do
      Excon.stub({}, lambda do |params|
        expect(params[:path]).to eq("/write")
        expect(params[:body]).to eq("foobar")
        expect(params[:query]).to eq("db" => "db0")
        {status: 204}
      end)
      n = client.writer(database: "db0").write("foobar")
      expect(n).to eq(6)
    end

    it "will set the database and retention policy with database/retention_policy" do
      Excon.stub({}, lambda do |params|
        expect(params[:path]).to eq("/write")
        expect(params[:body]).to eq("foobar")
        expect(params[:query]).to eq("db" => "db0", "rp" => "rp0")
        {status: 204}
      end)
      n = client.writer(database: "db0", retention_policy: "rp0").write("foobar")
      expect(n).to eq(6)
    end
  end
end
