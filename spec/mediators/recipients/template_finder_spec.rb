require "spec_helper"

describe Mediators::Recipients::TemplateFinder do
  it "throws exception when the env var is not found" do
    expect {
      described_class.run(template: "kwyjibo")
    }.to raise_error(Mediators::Recipients::NotFound)
  end

  it "returns proper email / body" do
    described_class.setup(template: "alerting", title: "title", body: "body") do
      expect(described_class.run(template: "alerting")).to eql(["title", "body"])
    end
  end
end
