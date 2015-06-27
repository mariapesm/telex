require "spec_helper"

describe Mediators::Messages::Cleanup do
  before do
    @mediator = Mediators::Messages::Cleanup.new

    old_notification = Fabricate(:notification)
    old_message = old_notification.message
    old_message.update(created_at: Time.now - 60*60*24*31*4)
    old_followup = Fabricate(:followup, message: old_message)
    @old_things = [old_notification, old_message, old_followup]
    @old_user = old_notification.user
    @old_producer = old_message.producer

    current_notification = Fabricate(:notification)
    current_message = current_notification.message
    current_followup = Fabricate(:followup, message: current_message)
    @current_things = [current_notification, current_message, current_followup]
    @current_user = current_notification.user
    @current_producer = current_message.producer
  end

  it 'destroys *only* old messages, and therefore their followups and notifications' do
    @mediator.call

    [@old_user, @old_producer, @current_user, @current_producer].each do |thing|
      expect(thing).to exist
    end

    @current_things.each do |current_thing|
      expect(current_thing).to exist
    end

    @old_things.each do |old_thing|
      expect(old_thing).to_not exist
    end
  end
end
