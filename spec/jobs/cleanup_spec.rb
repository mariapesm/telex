require 'spec_helper'

describe Jobs::Cleanup, '#perform' do
  it 'uses the Cleanup mediator' do
    expect(Mediators::Messages::Cleanup).to receive(:run)
    Jobs::Cleanup.new.perform
  end
end
