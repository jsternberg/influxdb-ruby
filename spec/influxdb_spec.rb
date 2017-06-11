require "spec_helper"

RSpec.describe InfluxDB do
  it "has a version number" do
    expect(InfluxDB::VERSION).not_to be nil
  end
end
