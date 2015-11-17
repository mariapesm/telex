# Deployment

## Setup

You'll need to clone the repo, then join and set git remotes for staging and production.

```
$ git clone git@github.com:heroku/telex.git
$ heroku apps:join -a telex-staging
$ heroku git:remote -a telex-staging -r staging
$ heroku apps:join -a telex
$ git:remote -a telex -r production
```

## Deploy to Staging:

```
$ heroku preauth -a telex-staging
$ git push staging master
```

## Test in Staging:

First, create a new producer on staging or update the api key for an existing one https://github.com/heroku/engineering-docs/blob/master/components/telex/user-guide.md#create-a-new-producer

Now send a test message to see if it goes through:

```ruby
require 'minitel'

# create a client
client = Minitel::Client.new("https://user:pass@telex-staging.herokuapp.com")

# send a notification to the owner and collaborators of an app
client.notify_app(app_uuid: '...', title: 'Your database is on fire!', body: 'Sorry.')
# => {"id"=>"uuid of message"}
```

## Deploy to Production:

```
$ heroku preauth -a telex
$ git push production master
```
