require "spec_helper"

describe Mediators::Recipients::Creator do
  before do
    producer = Fabricate(:producer)
    @app_info = {
      "id" => SecureRandom.uuid,
      "name" => "brat",
    }
    @creator = described_class.new(app_info: @app_info,
                                   email: "foo@bar.com")
  end

  it "creates a recipient" do
    allow(Mediators::Recipients::Emailer).to receive(:run).with(app_info: @app_info, recipient: kind_of(Recipient))
    
    result = nil
    expect{ result = @creator.call }.to change(Recipient, :count).by(1)
    expect(result).to be_instance_of(Recipient)
  end
end
