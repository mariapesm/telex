require "spec_helper"

describe Endpoints::AppAPI::Recipients do
  include Rack::Test::Methods

  let :heroku_client do
    Telex::HerokuClient.new(api_key: 'a_very_secret_api_key')
  end

  let :app_id do
    HerokuApiStub::APP_ID
  end

  before do
    stub_heroku_api
    Pliny::RequestStore.store[:heroku_client] = heroku_client
  end

  describe "GET /apps/:app_id/recipients" do
    it "succeeds" do
      get "/#{app_id}/recipients"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end
  end

  describe "POST /apps/:app_id/recipients" do
    bodies = [
      '{}',
      '',
      '{"email":""}',
      '{"email":"foo@example.com"}',
    ]

    bodies.each do |body|
      it "400s with request body = `#{body}`" do
        Fabricate(:recipient, email: "foo@example.com", app_id: app_id)

        post "#{app_id}/recipients", body
        expect(last_response.status).to eq(400)
      end
    end

    it "can create a new recipient" do
      post "/#{app_id}/recipients", { email: "yolo@yolo.com" }.to_json
      expect(last_response.status).to eq(201)

      expect(Recipient[email: "yolo@yolo.com", app_id: app_id]).to_not be_nil
    end
  end

  describe "PUT /apps/:app_id/recipients/:id/verify" do
    let :recipient do
      Fabricate(:recipient, app_id: app_id)
    end

    it "404s on expired token" do
      recipient.update(verification_sent_at: Time.now.utc - (Recipient::VERIFICATION_TOKEN_TTL * 2))

      put "/#{app_id}/recipients/#{recipient.id}/verify", { token: recipient.verification_token }.to_json
      expect(last_response.status).to eq(404)
    end

    it "404s on bad token" do
      put "/#{app_id}/recipients/#{recipient.id}/verify", { token: "" }.to_json
      expect(last_response.status).to eq(404)
    end

    it "404s on bad recipient id" do
      put "/#{app_id}/recipients/#{SecureRandom.uuid}/verify", { token: "" }.to_json
      expect(last_response.status).to eq(404)
    end

    it "verifies the recipient" do
      put "/#{app_id}/recipients/#{recipient.id}/verify", { token: recipient.verification_token }.to_json
      expect(last_response.status).to eq(204)

      recipient.reload
      expect(recipient.verified).to eq(true)
      expect(recipient.active).to eq(true)
    end
  end

  describe "PATCH /apps/:app_id/recipients/:id" do
    let :recipient do
      Fabricate(:recipient, app_id: app_id)
    end

    it "allows a token refresh" do
      old_token = recipient.verification_token
      patch "/#{app_id}/recipients/#{recipient.id}", { refresh: true }.to_json
      expect(last_response.status).to eq(200)

      recipient.reload
      expect(recipient.verification_token).to_not eq(old_token)
    end

    it "allows to de-activate" do
      patch "/#{app_id}/recipients/#{recipient.id}", { active: false }.to_json
      expect(last_response.status).to eq(200)

      recipient.reload
      expect(recipient.active).to eq(false)
    end
  end

  describe "DELETE /apps/:app_id/recipients/:id" do
    it "deletes the recipient" do
      recipient = Fabricate(:recipient, app_id: app_id)

      delete "/#{app_id}/recipients/#{recipient.id}"
      expect(last_response.status).to eq(204)

      expect(Recipient[recipient.id]).to eq(nil)
    end
  end
end
