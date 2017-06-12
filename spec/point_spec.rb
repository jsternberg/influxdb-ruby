require "spec_helper"

describe InfluxDB::Point do
  it "requires a name parameter" do
    expect {
      InfluxDB::Point.new
    }.to raise_error(ArgumentError)
  end

  it "will create a point with only a name" do
    pt = InfluxDB::Point.new(name: "cpu")
    expect(pt.name).to eq("cpu")
    expect(pt.tags).to eq({})
    expect(pt.fields).to eq({})
  end

  it "will create a point with tags" do
    pt = InfluxDB::Point.new(name: "cpu", tags: {host: "server01"})
    expect(pt.name).to eq("cpu")
    expect(pt.tags).to eq({host: "server01"})
    expect(pt.fields).to eq({})
  end

  it "will create a point with fields" do
    pt = InfluxDB::Point.new(name: "cpu", fields: {value: 2.0})
    expect(pt.name).to eq("cpu")
    expect(pt.tags).to eq({})
    expect(pt.fields).to eq({value: 2.0})
  end

  it "will create a point with tags and fields" do
    pt = InfluxDB::Point.new(name: "cpu", tags: {host: "server01"}, fields: {value: 2.0})
    expect(pt.name).to eq("cpu")
    expect(pt.tags).to eq({host: "server01"})
    expect(pt.fields).to eq({value: 2.0})
  end

  it "will change the fields with with_fields" do
    pt = InfluxDB::Point.new(name: "cpu").
      with_fields(value: 2.0)
    expect(pt.name).to eq("cpu")
    expect(pt.tags).to eq({})
    expect(pt.fields).to eq({value: 2.0})
  end

  it "will change the tags with with_tags" do
    pt = InfluxDB::Point.new(name: "cpu").
      with_tags(host: "server01")
    expect(pt.name).to eq("cpu")
    expect(pt.tags).to eq({host: "server01"})
    expect(pt.fields).to eq({})
  end

  it "will use the protocol from the writer" do
    pt = InfluxDB::Point.new(name: "cpu").
      with_fields(value: 2.0)
    writer = double()
    protocol = double()
    expect(protocol).to receive(:encode).with(writer, pt)
    expect(writer).to receive(:protocol) { protocol }
    pt.write_to(writer)
  end
end
