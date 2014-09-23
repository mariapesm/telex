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
    @id = SecureRandom.uuid
    stub_heroku_api
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

  it 'returns an array of one user with role' do
    response = @finder.call
    expect(response).to be_kind_of(Array)
    expect(response.size).to eq(1)

    uwr = response.first
    expect(uwr.role).to eq(:self)
    expect(uwr.user.heroku_id).to eq(@id)
  end
end

describe AppUserFinder, "#call" do
  before do
    @id = "01234567-89ab-cdef-0123-456789abcdef"
    @finder = AppUserFinder.new(target_id: @id)

    @owner_id   = HerokuApiStub::OWNER_ID
    @collab1_id = HerokuApiStub::COLLAB1_ID
    @collab2_id = HerokuApiStub::COLLAB2_ID

    stub_heroku_api
  end

  it 'creates users locally if needed' do
    expect(User[heroku_id: @owner_id]).to   be_nil
    expect(User[heroku_id: @collab1_id]).to be_nil
    expect(User[heroku_id: @collab2_id]).to be_nil
    @finder.call

    owner   = User[heroku_id: @owner_id]
    expect(owner.email).to eq('username@example.com')
    collab1 = User[heroku_id: @collab1_id]
    expect(collab1.email).to eq('username2@example.com')
    collab2 = User[heroku_id: @collab2_id]
    expect(collab2.email).to eq('username3@example.com')
  end

  it 'updates the email for users' do
    User.create(heroku_id: @owner_id, email: 'outdated@email.com')
    @finder.call
    user = User[heroku_id: @owner_id]
    expect(user.email).to eq('username@example.com')
  end

  it 'returns an array of users with roles' do
    result = @finder.call
    owner = result.detect {|uwr| uwr.role == :owner }
    expect(owner.user.heroku_id).to eq(@owner_id)

    collab1 = result.detect {|uwr| uwr.user.heroku_id == @collab1_id }
    expect(collab1.role).to eq(:collaborator)
  end
end
