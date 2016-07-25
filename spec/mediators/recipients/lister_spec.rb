require "spec_helper"

describe Mediators::Recipients::Lister do
  let(:app_id) { SecureRandom.uuid }

  let(:active) { Fabricate(:recipient, app_id: app_id, active: true, verified: true) }
  let(:inactive) { Fabricate(:recipient, app_id: app_id, active: false, verified: true) }
  let(:unverified) { Fabricate(:recipient, app_id: app_id, active: false, verified: false) }

  it "lists inactive, verified, unverified" do
    results = described_class.run(app_info: { "id" => app_id })
    expect(results).to include(active)
    expect(results).to include(inactive)
    expect(results).to include(unverified)
  end

  it "does not list unrelated apps" do
    other = Fabricate(:recipient)
    results = described_class.run(app_info: { "id" => app_id })
    expect(results).to_not include(other)
  end
end
