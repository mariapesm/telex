require 'spec_helper'

describe Telex::Emailer do
  let(:emailer) { Telex::Emailer.new(email: 'foo@bar.com', subject: 'hi', body: 'ohhai') }
  let(:mail)    { emailer.deliver! }

  it 'sets from' do
    expect(mail.from).to eq(%w( bot@heroku.com ))
  end

  it 'sets the subject' do
    expect(mail.subject).to eq('hi')
  end
end
