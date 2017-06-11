describe InfluxDB::Protocol do
  context "when using protocol v1" do
    subject(:protocol) { InfluxDB::Protocol::V1.new }

    it "will raise an error when encoding a point with no fields" do
      pt = InfluxDB::Point.new(name: "cpu")
      w = StringIO.new
      expect {
        protocol.encode(w, pt)
      }.to raise_error(InfluxDB::NoFieldsError)
    end

    it "will encode a float value" do
      pt = InfluxDB::Point.new(name: "cpu").
        with_fields(value: 2.0)
      w = StringIO.new
      protocol.encode(w, pt)
      expect(w.string).to eq("cpu value=2.0\n")
    end

    it "will encode a integer value" do
      pt = InfluxDB::Point.new(name: "cpu").
        with_fields(value: 2)
      w = StringIO.new
      protocol.encode(w, pt)
      expect(w.string).to eq("cpu value=2i\n")
    end

    it "will encode a string value" do
      pt = InfluxDB::Point.new(name: "cpu").
        with_fields(value: "foo")
      w = StringIO.new
      protocol.encode(w, pt)
      expect(w.string).to eq("cpu value=\"foo\"\n")
    end

    it "will encode a true value" do
      pt = InfluxDB::Point.new(name: "cpu").
        with_fields(value: true)
      w = StringIO.new
      protocol.encode(w, pt)
      expect(w.string).to eq("cpu value=t\n")
    end

    it "will encode a false value" do
      pt = InfluxDB::Point.new(name: "cpu").
        with_fields(value: false)
      w = StringIO.new
      protocol.encode(w, pt)
      expect(w.string).to eq("cpu value=f\n")
    end

    it "will throw an error when encoding an invalid field type" do
      pt = InfluxDB::Point.new(name: "cpu").
        with_fields(value: [])
      w = StringIO.new
      expect {
        protocol.encode(w, pt)
      }.to raise_error(InfluxDB::InvalidFieldType)
    end

    it "will have a content type" do
      expect(protocol.content_type).to eq("application/x-influxdb-line-protocol-v1")
    end
  end
end
