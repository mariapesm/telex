require "spec_helper"
include Mediators::Messages

describe UserFinder, '.from_message' do
  def finder_from_message_type(type)
    message = instance_double(Message, target_type: type, target_id: SecureRandom.uuid)
    UserFinder.from_message(message)
  end

  it 'creates a finder for messages targiting a user' do
    expect( finder_from_message_type('user') ).to be_instance_of(UserUserFinder)
  end

  it 'creates a finder for messages targiting an app' do
    expect( finder_from_message_type('app') ).to be_instance_of(AppUserFinder)
  end

  it 'blows up on messages with strange types' do
    expect{ finder_from_message_type('nonsense') }.to raise_error
  end
end

describe UserUserFinder, "#call" do
  before do
    @id = "01234567-89ab-cdef-0123-456789abcdef"
    allow(Telex::HerokuClient).to receive(:account_info)
      .with(@id)
      .and_return({
        "allow_tracking" => true,
        "beta" => false,
        "created_at" => "2012-01-01T12:00:00Z",
        "email" => "username@example.com",
        "id" => @id,
        "last_login" => "2012-01-01T12:00:00Z",
        "name" => "Tina Edmonds",
        "two_factor_authentication" => false,
        "updated_at" => "2012-01-01T12:00:00Z",
        "verified" => false
      })
    @finder = UserUserFinder.new(target_id: @id)
  end

  it 'creates the user locally if needed' do
    expect(User[heroku_id: @id]).to be_nil
    @finder.call
    user = User[heroku_id: @id]
    expect(user).to_not be_nil
    expect(user.email).to eq('username@example.com')
  end

  it 'updates the email for the user' do
    User.create(heroku_id: @id, email: 'outdated@email.com')
    @finder.call
    user = User[heroku_id: @id]
    expect(user.email).to eq('username@example.com')
  end

  it 'returns the user' do
    response = @finder.call
    expect(response).to be_kind_of(Array)
    expect(response.size).to eq(1)
    expect(response.first.heroku_id).to eq(@id)
  end
end

describe AppUserFinder, "#call" do
  it 'creates users locally if needed'
  it 'updates the email for users'
end
