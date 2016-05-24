require 'spec_helper'
require 'rexml/document'

describe Telex::Emailer do
  let(:options) {{ email: 'foo@bar.com', subject: 'hi', body: 'ohhai' }}
  let(:emailer) { Telex::Emailer.new(options) }

  it 'sets from' do
    mail = emailer.deliver!
    expect(mail.from).to eq(%w( bot@heroku.com ))
  end

  it 'sets a custom from' do
    options.merge!(from: 'api@heroku.com')
    mail = emailer.deliver!
    expect(mail.from).to(eq(%w( api@heroku.com )))
  end

  it 'sets the subject' do
    mail = emailer.deliver!
    expect(mail.subject).to eq('hi')
  end

  it 'raises DeliverError on delivery errors' do
    allow(Mail).to receive(:new) { raise Net::ReadTimeout }
    expect { emailer.deliver! }.to raise_error(Telex::Emailer::DeliveryError)
  end

  # see https://developers.google.com/gmail/markup/actions/actions-overview
  describe 'ld+json support for action shortcuts in GMail' do
    before do
      options.merge!(action: { label: 'View app', url: 'https://foo' })
    end

    it 'adds a script to the html body' do
      mail = emailer.deliver!
      doc = REXML::Document.new(mail.html_part.body.decoded)
      script = doc.get_elements("//script").first
      expect(script.attributes["type"]).to eq('application/ld+json')
      ld_json = MultiJson.load(script.text)
      expect(ld_json['@context']).to eq('http://schema.org')
      expect(ld_json.dig('potentialAction', '@type')).to eq('ViewAction') # only supported Gmail type for now
      expect(ld_json.dig('potentialAction', 'name')).to eq('View app')
      expect(ld_json.dig('potentialAction', 'target')).to eq('https://foo')
    end
  end
end
